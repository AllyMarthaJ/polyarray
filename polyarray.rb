Dir[File.join(__dir__, "lib", "*.rb")].each { |file| load file }

Dir[File.join(__dir__, "lib", "ext", "*.rb")].each { |file| load file }
