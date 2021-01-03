require 'fileutils'
require 'digest'
require_relative 'ast/node'
require_relative 'artifact'


class StaticAnalyzer
  def initialize(opts)
    @opts = opts
    @artifacts = []
  end

  def run
    validate_opts
    create_workspace
    @codebase = @opts.positional.first
    start_parsing
    run_tasks
  end

  def start_parsing
    if File.file?(@codebase)
      parse_single_file
    else
      puts "Only single file supported"
    end
  end

  def run_tasks
    @config = {
      sinks: {
        vuln: { dangerous_params: [0] },
      },
      sources: [:from_user]
    }

    @artifacts.each do |artifact|
      reaching_definition_analysis(artifact)
      taint_analysis(artifact)

      create_dir_for_pngs(artifact)
      save_asts(artifact) if @opts.ast2png
      save_cfgs(artifact) if @opts.cfg2png

      find_vulns(artifact) if @opts.find_vulns
    end
  end

  def reaching_definition_analysis(artifact)
    artifact.functions.each do |function|
      puts "[*] Computing reaching definition for #{function.name}"
      function.cfg.reach_definition_analysis
      puts "=" * 80
    end
  end

  def taint_analysis(artifact)
    artifact.functions.each do |function|
      puts "[*] Computing taint propagation for #{function.name}"
      #function.cfg.taint_analysis(config)
      function.cfg.compute_taint_propagation(@config)
      puts "=" * 80
    end
  end

  def find_vulns(artifact)
    artifact.functions.each do |function|
      puts "[*] Finding dangerous fcall in #{function.name}"
      #function.cfg.taint_analysis(config)
      function.cfg.find_dangerous_fcall(@config)
      function.vulnerabilities.each do |vuln|
        out = "    Trace:\n"
        vuln[:trace].each_with_index do |line, i|
          pad = ' '*(i*2)
          out << "     #{pad} Location: #{function.path}:#{line}\n"
        end
        puts out
      end
      puts "=" * 80
    end
  end

  def artifact_png_dir(artifact)
    hexdigest = Digest::SHA1.hexdigest(artifact.path)[0...7]
    artifact_dir = "#{File.basename(artifact.path)}_FILES_#{hexdigest}"
    artifact_dir = File.join(@opts.workspace, artifact_dir)
    File.join(artifact_dir, 'pngs')
  end

  def create_dir_for_pngs(artifact)
    pngs_dir = artifact_png_dir(artifact)
    FileUtils.mkdir_p(pngs_dir) unless File.directory?(pngs_dir)
    pngs_dir
  end

  def save_asts(artifact)
    pngs_dir = artifact_png_dir(artifact)

    #png_file = File.join(pngs_dir, 'full.ast.png')
    #artifact.ast.save_png(png_file)

    artifact.functions.each do |function|
      puts "[*] Saving AST of #{function.name}"
      png_file = File.join(pngs_dir, "#{function.name}.ast.png")
      function.ast.save_png(png_file)
      puts "=" * 80
    end
  end

  def save_cfgs(artifact)
    pngs_dir = artifact_png_dir(artifact)
    artifact.functions.each do |function|
      puts "[*] Saving CFG of #{function.name}"
      png_file = File.join(pngs_dir, "#{function.name}.cfg.png")
      function.cfg.save_png(png_file)
      puts "=" * 80
    end
  end

  def parse_single_file
    @artifacts << Artifact.new(@codebase)
  end

  def validate_opts
    if @opts.positional.empty?
      puts "Filename or codebase not passed"
      exit 1
    end

    if @opts.workspace.nil?
      puts "Workspace not passed"
      exit 1
    end
  end

  def create_workspace
    FileUtils.mkdir_p(@opts.workspace) unless File.directory?(@opts.workspace)
  end
end

