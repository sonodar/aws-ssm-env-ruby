module AwsSsmEnv
  class ParameterSetter
    def initialize(**args); 
      @overwrite = overwrite?(args)
      @scope = scope?(args)
    end

    def save(name, value)
      if @scope[name] && !@overwrite
        return
      end
      @scope[name] = value
    end

    def scope
      @scope
    end

    private

    def overwrite?(overwrite: nil, **)
      if overwrite.nil?
        false
      else
        overwrite.to_s.downcase == 'true'
      end
    end

    def scope?(**args)
      scope_type = args[:scope]
      case scope_type
      when nil
        ENV
      else
        unless scope_type.is_a?(OpenStruct)
          raise ArgumentError, 'Possible values for :scope are either :environment or an "OpenStruct" implementation class.'
        end
        scope_type
      end
    end

  end

end
