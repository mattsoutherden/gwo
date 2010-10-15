module GWO
  module Helper
    def gwo_for(options = {}, &block)
      options[:erb_context] = self
      GWO::Experiment.new(options, &block)
    end
    
    def gwo_start(experiment_id, options = { :type => 'multivariate'})
      %{<script type="text/javascript">
function utmx_section(){}function utmx(){}
(function(){var k='#{experiment_id}',d=document,l=d.location,c=d.cookie;function f(n){
if(c){var i=c.indexOf(n+'=');if(i>-1){var j=c.indexOf(';',i);return c.substring(i+n.
length+1,j<0?c.length:j)}}}var x=f('__utmx'),xx=f('__utmxx'),h=l.hash;
d.write('<sc'+'ript src="'+
'http'+(l.protocol=='https:'?'s://ssl':'://www')+'.google-analytics.com'
+'/siteopt.js?v=1&utmxkey='+k+'&utmx='+(x?x:'')+'&utmxx='+(xx?xx:'')+'&utmxtime='
+new Date().valueOf()+(h?'&utmxhash='+escape(h.substr(1)):'')+
'" type="text/javascript" charset="utf-8"></sc'+'ript>')})();
</script>}.tap do |js|
        js << %{<script>utmx("url",'A/B');</script>} if options[:type] == 'ab'
      end
    end
    
    def gwo_end(experiment_id, ga_acct)
      %{<script type="text/javascript">
if(typeof(_gat)!='object')document.write('<sc'+'ript src="http'+
(document.location.protocol=='https:'?'s://ssl':'://www')+
'.google-analytics.com/ga.js"></sc'+'ript>')</script>
<script type="text/javascript">
try {
var pageTracker=_gat._getTracker("#{ga_acct}");
pageTracker._trackPageview("/#{experiment_id}/test");
}catch(err){} </script>
      }
    end
    
    def gwo_conversion(experiment_id, ga_acct)
      %{<script type="text/javascript">
if(typeof(_gat)!='object')document.write('<sc'+'ript src="http'+
(document.location.protocol=='https:'?'s://ssl':'://www')+
'.google-analytics.com/ga.js"></sc'+'ript>')</script>
<script type="text/javascript">
try {
var pageTracker=_gat._getTracker("#{ga_acct}");
pageTracker._trackPageview("/#{experiment_id}/goal");
}catch(err){} </script>
      }
    end
    
    def gwo_section_control(section_name, content = nil, &block)
      concat(%{<!-- utmx section name="#{section_name}" -->
<script type="text/javascript">
var gwoVariation = utmx("variation_number", "#{section_name}");
if(gwoVariation != undefined && gwoVariation != 0) document.write("<noscript>");
</script>
})
      
      content ||= ''
      content += capture(&block) if block_given?
      # TODO strip or rewrite <noscript> tags
      concat(content)
      
      concat(%{\n</noscript>\n})
    end
    
    def gwo_section_variation(section_name, variation_number, content = nil, &block)
      concat(%{<script type="text/javascript">
var gwoVariation = utmx("variation_number", "#{section_name}");
if(gwoVariation != undefined && gwoVariation == #{variation_number}) document.write('</noscript a="')</script> <!-- " >
})
      
      content ||= ''
      content += capture(&block) if block_given?
      # TODO strip or rewrite HTML comments
      concat(content)
      
      concat(%{<script type="text/javascript"> document.write('<' + '!' + '-' + '-'); </script>  -->
})
    end
  end
end
