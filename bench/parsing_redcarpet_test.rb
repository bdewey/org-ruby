require 'redcarpet'
require 'benchmark'

def run_benchmark(n=30)
  org_content = File.open('bench.org').read

  puts "Parsing #{n} times"
  markdown = Redcarpet::Markdown.new(Redcarpet::Render::HTML)
  Benchmark.bmbm do |x|    
    x.report('html conversion with Redcarpet') do
      n.times do
        markdown.render(org_content)
      end
    end
  end
end

puts "Running benchmark with RedCarpet with Ruby #{RUBY_VERSION} (n=30)"
run_benchmark
