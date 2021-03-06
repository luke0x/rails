module ActionController
  module RenderOptions
    extend ActiveSupport::DependencyModule
    
    included do
      extlib_inheritable_accessor :_renderers
      self._renderers = []
    end
    
    def render_to_body(options)
      _renderers.each do |renderer|
        if options.key?(renderer)
          _process_options(options)
          return send("_render_#{renderer}", options[renderer], options)
        end
      end
      super
    end
  end
  
  module Renderers
    module Json
      extend ActiveSupport::DependencyModule
      
      depends_on RenderOptions
      
      included do
        _renderers << :json
      end
      
      def _render_json(json, options)
        json = ActiveSupport::JSON.encode(json) unless json.respond_to?(:to_str)
        json = "#{options[:callback]}(#{json})" unless options[:callback].blank?
        response.content_type ||= Mime::JSON
        self.response_body = json
      end      
    end
  end
end