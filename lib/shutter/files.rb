module Shutter
  class Files
    include Shutter::Content
    
    class << self
      def create(dir, overwrite=false, except=[])
        CONFIG_FILES.each do |name|
          file = "#{@config_path}/#{name}"
          if !File.exists?(file) || overwrite || except.include?(name)
            File.open(file, 'w') do |f| 
              f.write(const_get(name.upcase.gsub(/\./, "_")))
            end
          end
        end
      end

      def create_config_dir(config_path)
        # Check to see if the path to the config files exist
        unless File.directory?(config_path)
          begin
            Dir.mkdir(config_path)
          rescue Errno::ENOENT
            raise "Could not create the configuration directory.  Check to see if the parent directory exists."
          end
        end
      end
    end

  end
end