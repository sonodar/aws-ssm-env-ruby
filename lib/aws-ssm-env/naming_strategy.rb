module AwsSsmEnv
  class NamingStrategy
    def parse_name(parameter); end
  end

  class BasenameNamingStrategy < NamingStrategy
    def parse_name(parameter)
      File.basename(parameter.name)
    end
  end
end
