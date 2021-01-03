# Description

This is not a real static analyzer but a toy project to learn and put ideas and algorithm into practice.

# Limitations
* The things already implemented operate on named function only
* No module or class support
* Very very simple intraprocedural taint analysis
* No sanitization support

# How to test it
```
ruby main.rb --ast2png --cfg2png --find-vulns -w workspac0 samples/vuln.rb
[*] Computing reaching definition for func0
================================================================================
[*] Computing reaching definition for func1
================================================================================
[*] Computing reaching definition for func2
================================================================================
[*] Computing reaching definition for func3
================================================================================
[*] Computing reaching definition for func4
================================================================================
[*] Computing reaching definition for func5
================================================================================
[*] Computing taint propagation for func0
================================================================================
[*] Computing taint propagation for func1
================================================================================
[*] Computing taint propagation for func2
================================================================================
[*] Computing taint propagation for func3
================================================================================
[*] Computing taint propagation for func4
================================================================================
[*] Computing taint propagation for func5
================================================================================
[*] Saving AST of func0
================================================================================
[*] Saving AST of func1
================================================================================
[*] Saving AST of func2
================================================================================
[*] Saving AST of func3
================================================================================
[*] Saving AST of func4
================================================================================
[*] Saving AST of func5
================================================================================
[*] Saving CFG of func0
================================================================================
[*] Saving CFG of func1
================================================================================
[*] Saving CFG of func2
================================================================================
[*] Saving CFG of func3
================================================================================
[*] Saving CFG of func4
================================================================================
[*] Saving CFG of func5
================================================================================
[*] Finding dangerous fcall for func0
    Trace:
      Location: samples/vuln.rb:5
================================================================================
[*] Finding dangerous fcall for func1
    Trace:
      Location: samples/vuln.rb:9
        Location: samples/vuln.rb:10
================================================================================
[*] Finding dangerous fcall for func2
================================================================================
[*] Finding dangerous fcall for func3
================================================================================
[*] Finding dangerous fcall for func4
    Trace:
      Location: samples/vuln.rb:30
        Location: samples/vuln.rb:34
================================================================================
[*] Finding dangerous fcall for func5
    Trace:
      Location: samples/vuln.rb:38
        Location: samples/vuln.rb:41
          Location: samples/vuln.rb:45
================================================================================

```
