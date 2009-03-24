module GWO
  class Experiment
    attr_writer :experiment_id, :ga_acct
    
    # GWO::Experiment.new(:experiment_id => '123123', :ga_acct => 'UA-123-123')
    def initialize(options = {})
      @experiment_id = options[:experiment_id]
      @ga_acct = options[:ga_acct]
      @erb_context = options[:erb_context]
      render(){ yield(self) } if block_given?
      self
    end
    
    # Returns the current experiment_id value or sets it if a value is passed
    #
    # Allows you to do something like:
    #   GWO::Experiment.new().experiment_id('123123').ga_acct('UA-123-123').render do |exp| ...
    #
    def experiment_id(experiment_id = nil)
      return @experiment_id unless experiment_id      
      @experiment_id = experiment_id
      self
    end
    
    # Returns the current ga_acct value or sets it if a value is passed
    def ga_acct(ga_acct = nil)
      return @ga_acct unless ga_acct
      @ga_acct = ga_acct
      self
    end
    
    def erb_context(erb_context = nil)
      return @erb_context unless erb_context
      @erb_context = erb_context
      self
    end
    
    def render(&block)
      yield(self)
      @erb_context.concat self.end()
    end
    
    def start()
      return '' if @start_called # Start only needs to be called once
      @start_called = true
      @erb_context.gwo_start(@experiment_id)
    end
    
    def end()
      return '' if @end_called
      @end_called = true
      @erb_context.gwo_end(@experiment_id, @ga_acct)
    end
    
    def conversion()
      @erb_context.gwo_conversion(@experiment_id, @ga_acct)
    end
    
    def section(name)
      start()
      section = Section.new(self, name)
      yield(section) if block_given?
      section
    end
    
    def section_control(name, content = nil, &block)
      start()
      @erb_context.gwo_section_control(name, content, &block)
    end
    
    def section_variation(name, variation_number, content = nil, &block)
      @erb_context.gwo_section_variation(name, variation_number, content, &block)
    end
    
  end
  
  class Section
    def initialize(experiment, name)
      @experiment = experiment
      @name = name
    end
    
    def control(content = nil, &block)
      @experiment.section_control(@name, content, &block)
    end
    
    def variation(variation_number, content = nil, &block)
      @experiment.section_variation(@name, variation_number, content, &block)
    end
  end
end