module Ikura
  module Builder
    def self.append(target, content)
      %(<turbo-stream action="append" target="#{target}"><template>#{content}</template></turbo-stream>)
    end
  end
end
