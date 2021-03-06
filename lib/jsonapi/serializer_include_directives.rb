module JSONAPI
  class SerializerIncludeDirectives

    # Construct an IncludeDirectives Hash from an array of dot separated include strings.
    # For example [:posts, 'posts.comments', 'posts.comments.tags']
    # will transform into =>
    # {
    #   :posts=>{
    #     :include=>true,
    #     :include_related=>{
    #       :comments=>{
    #         :include=>true,
    #         :include_related=>{
    #           :tags=>{
    #             :include=>true
    #           }
    #         }
    #       }
    #     }
    #   }
    # }

    def initialize(includes_array)
      @include_directives_hash = {include_related: {}}
      includes_array.each do |include|
        parse_include(include)
      end
    end

    def include_directives
      @include_directives_hash
    end

    private
    def get_related(current_path)
      current = @include_directives_hash
      current_path.split('.').each do |fragment|
        fragment = fragment.to_sym
        current[:include_related][fragment] ||= {include: false, include_related: {}}
        current = current[:include_related][fragment]
      end
      current
    end

    def parse_include(include)
      parts = include.split('.')
        local_path = ''
      parts.each_with_index do |part, index|
        local_path += local_path.length > 0 ? ".#{part}" : part
        related = get_related(local_path)
        if index == parts.length - 1
          related[:include] = true
        end
      end
    end
  end
end
