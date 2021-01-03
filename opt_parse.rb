require 'optparse'
require 'ostruct'


def parse_opts(args)
  user_opts = OpenStruct.new
  user_opts.ast2png = false
  user_opts.cfg2png = false
  user_opts.cg2png  = false
  user_opts.find_vulns = false
  user_opts.workspace = nil
  user_opts.positional = []

  opt_parser = OptionParser.new do |opts|
    opts.banner = 'Usage: main [options] <filename>'

    opts.on('--ast2png', 'Save PNG images for Abstract Syntax Tree (AST)') do
      user_opts.ast2png = true
    end

    opts.on('--cfg2png', 'Save PNG images for Control Flow Graph (CFG)') do
      user_opts.cfg2png = true
    end

    #opts.on('--cg2png', 'Save PNG images for CallGraph (CG)') do
    #  user_opts.cg2png = true
    #end

    opts.on('--find-vulns', 'Find vulns') do
      user_opts.find_vulns = true
    end

    opts.on('-w', '--workspace=WORKSPACE', 'Path to save results') do |workspace|
      user_opts.workspace = workspace
    end
  end

  user_opts.positional = opt_parser.parse!(args)
  user_opts
end
