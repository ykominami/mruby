MRuby::CrossBuild.new('ARM') do |conf|
#  conf.convert_mode = :CYGWIN_TO_WIN_WITH_ESCAPE

  toolchain :gcc
  conf.cc.defines = %w(DISABLE_STDIO)
  conf.bins = []

  [conf.cc, conf.objc, conf.asm].each do |cc|
    cc.command_requirement = :WINDOWS_STYLE_PATH
    cc.command = ENV['CC'] || 'arm-none-eabi-gcc'
    cc.flags = [ENV['CFLAGS'] || %w(-g -std=gnu99 -O3 -Wall -Werror-implicit-function-declaration)]
    cc.include_paths = ["#{MRUBY_ROOT}/include"],

    cc.defines = %w(DISABLE_GEMS)
    cc.option_include_path = '-I%s'
    cc.option_define = '-D%s'
    cc.compile_options = '%{flags} -MMD -o %{outfile} -c %{infile}'
  end

  [conf.cxx].each do |cxx|
    cxx.command_requirement = :WINDOWS_STYLE_PATH
    cxx.command = ENV['CXX'] || 'arm-none-eabi-g++'
    cxx.flags = [ENV['CXXFLAGS'] || ENV['CFLAGS'] || %w(-g -O3 -Wall -Werror-implicit-function-declaration)]
    cxx.include_paths = ["#{MRUBY_ROOT}/include"]
    cxx.defines = %w(DISABLE_GEMS)
    cxx.option_include_path = '-I%s'
    cxx.option_define = '-D%s'
    cxx.compile_options = '%{flags} -MMD -o %{outfile} -c %{infile}'
  end

  conf.linker do |linker|
    linker.command_requirement = :WINDOWS_STYLE_PATH
    linker.command = ENV['LD'] || 'arm-none-eabi-gcc'
    linker.flags = [ENV['LDFLAGS'] || %w()]
    linker.libraries = %w(m)
    linker.library_paths = []
    linker.option_library = '-l%s'
    linker.option_library_path = '-L%s'
    linker.link_options = '%{flags} -o %{outfile} %{objs} %{flags_before_libraries} %{libs} %{flags_after_libraries}'
  end

  # Archiver settings
  conf.archiver do |archiver|
    archiver.command_requirement = :WINDOWS_STYLE_PATH
    archiver.command = ENV['AR'] || 'arm-none-eabi-ar'
  end
  #
  #   conf.cc.flags << "-m32"
  #   conf.linker.flags << "-m32"
    #
  # Use standard print/puts/p
  conf.gem :core => "mruby-print"
  # Use extended toplevel object (main) methods
  conf.gem :core => "mruby-toplevel-ext"
  # Use standard Math module
  #  conf.gem :core => "mruby-math"
  # Use mruby-compiler to build other mrbgems
  conf.gem :core => "mruby-compiler"
  conf.gem :core => "mruby-array-ext"
  conf.build_mrbtest_lib_only
=begin
  # Use standard Kernel#sprintf method
  conf.gem :core => "mruby-sprintf"
  # Use standard Time class
  # conf.gem :core => "mruby-time"
  # Use standard Struct class
  conf.gem :core => "mruby-struct"
  # Use extensional Enumerable module
  conf.gem :core => "mruby-enum-ext"
  # Use extensional String class
  #conf.gem :core => "mruby-string-ext"
  # Use extensional Numeric class
  conf.gem :core => "mruby-numeric-ext"
  # Use extensional Array class
  conf.gem :core => "mruby-array-ext"
  # Use extensional Hash class
  conf.gem :core => "mruby-hash-ext"
  # Use extensional Range class
  conf.gem :core => "mruby-range-ext"
  # Use extensional Proc class
  conf.gem :core => "mruby-proc-ext"
  # Use extensional Symbol class
  conf.gem :core => "mruby-symbol-ext"
  # Use Random class
  # conf.gem :core => "mruby-random"
  # Use extensional Object class
  conf.gem :core => "mruby-object-ext"
  # Use ObjectSpace class
  conf.gem :core => "mruby-objectspace"
  # Use Fiber class
  conf.gem :core => "mruby-fiber"
  # Use Enumerator class (require mruby-fiber)
  conf.gem :core => "mruby-enumerator"
  # Use Enumerable::Lazy classlin (require mruby-enumerator)
  conf.gem :core => "mruby-enum-lazy"
  # Generate mirb command
  # conf.gem :core => "mruby-bin-mirb"
  # Generate mruby command
  # conf.gem :core => "mruby-bin-mruby"
  # Generate mruby-strip command
  # conf.gem :core => "mruby-bin-strip"
=end
  #conf.gem :core => "mruby-tecs"
  #conf.gem :core => "mruby-bin-mruby"
  #conf.gem :core => "mruby-ev3-motor"
end
