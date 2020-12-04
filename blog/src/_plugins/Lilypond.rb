require 'tempfile'
require 'base64'
require 'digest'

module Jekyll
  class LilypondBlock < Liquid::Block
    @@last_render_time = nil
    @@counters = {}

    def initialize(tag_name, caption, tokens)
      super
      @caption = caption.strip
      reset_counters()
    end

    def reset_counters()
      @@counters = {}
      @@counters.default = 0
    end

    def incr_number(page_id)
      @@counters[page_id] += 1
    end

    def render_lilypond(content, scale, out_dir)
      Dir.mkdir(out_dir) unless Dir.exists?(out_dir)

      in_f = Tempfile.new(["music", ".ly"])
      header = <<-HEADER
  \\header {
    tagline = ""
  }
  \\paper {
    indent = 0\cm
  }
      HEADER
      in_f.write(header)
      in_f.write(content)
      in_f.close()

      out_f = Tempfile.new(["music", ".png"])
      out_path = out_f.path
      out_lilypond_name = out_path.sub(".png", "")

      out_name = Digest::SHA256.hexdigest(IO.read(in_f)) + ".#{scale}x.png"

      unless File.exists?(File.join(out_dir, out_name))
        %x[lilypond --format=png -dresolution=#{scale * 100} --output #{out_lilypond_name} #{in_f.path}]
        %x[gm convert #{out_path} -trim #{out_dir}/#{out_name}]
      end

      in_f.unlink

      return out_name
    end

    def render(context)
      site = context.registers[:site]
      page = context.registers[:page]

      reset_counters() if not @@last_render_time.nil? and site.time > @@last_render_time
      @@last_render_time = site.time

      number = incr_number(page.id)

      out_dir = "#{site.source}/generated"
      name_1x = render_lilypond(super, 1, out_dir)
      name_2x = render_lilypond(super, 2, out_dir)

      site.static_files << Jekyll::StaticFile.new(site, site.source, "/generated", name_1x)
      site.static_files << Jekyll::StaticFile.new(site, site.source, "/generated", name_2x)

      url_1x = "#{site.baseurl}/generated/#{name_1x}"
      url_2x = "#{site.baseurl}/generated/#{name_2x}"

      <<-MARKUP.strip
  <figure class="lilypond music">
  <span id="score-#{number}"></span>
  <img src="#{url_1x}" srcset="#{url_1x} 1x, #{url_2x} 2x" alt="#{@caption}" />
  <figcaption>
  <span class="caption-number">Score #{number}:</span>
  #{@caption}
  </figcaption>
  </figure>
      MARKUP
    end
  end
end

Liquid::Template.register_tag('lilypond', Jekyll::LilypondBlock)
