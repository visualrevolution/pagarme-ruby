module PagarMe
  class PagarMeObject

	if method_defined?(:id)
	  undef :id
	end

	def initialize(response = {})
	  @values = {}
	  refresh_from(response)
	end

	def self.construct_from(values)
	  object = self.new(values)
	  return object
	end

	def refresh_from(values)
	  instance_eval do
		remove_acessors(@values.keys)
		add_accessors(values.keys)
	  end
	  @values = Hash.new

	  values.each do |key,value|
		@values[key] = Util.convert_to_pagarme_object(value)
	  end
	end

	def each(&block)
	  @values.each(&block)
	end

	def []=(key,value)
	  @values[key] = value
	end

	def [](key)
	  @values[key.to_sym]
	end

	def to_hash
	  @values.each do |k,v|
			@values[k] = @values[k].to_hash if @values[k].kind_of?(PagarMeObject) 	
	  end
	end

	def inspect()
      id_string = (self.respond_to?(:id) && !self.id.nil?) ? " id=#{self.id}" : ""
      "#<#{self.class}:0x#{self.object_id.to_s(16)}#{id_string}> JSON: " + MultiJson.dump(@values, :pretty => true)
    end
	protected

	def metaclass
	  class << self; self; end
	end


	def remove_acessors(keys)
	  metaclass.instance_eval do
		keys.each do |key|
		  key_sym = :"#{key}="
		  remove_method(key) if method_defined?(key)
		  remove_method(key_sym) if method_defined?(key_sym)
		end
	  end
	end

	def add_accessors(keys)
	  metaclass.instance_eval do
		keys.each do |key| 
		  key_set = "#{key}="
		  define_method(key) { @values[key] }
		  define_method(key_set) do |value|
			if v == ""
			  raise ArgumentError.new("Voce nao pode atribuir a #{key} uma string vazia.")
			end
			@values[key] = value
		  end
		end
	  end
	end

	def method_missing(name, *args)
	  if name.to_s.end_with?('=')
		attr = name.to_s[0...-1].to_sym
		add_accessors([attr])
		begin
		  mth = method(name)
		rescue NameError
		  raise NoMethodError.new("O atributo #{name} nao e permitido.")
		end
		return mth.call(args[0])
	  else
		return @values[name] if @values.has_key?(name)
	  end
	end
  end
end
