#!/usr/bin/env ruby

require 'active_support/all'
quietly do
require 'boilerpipe'
require 'nokogiri'
require 'action_view'
require 'open-uri'
require 'classifier'
require 'pry'
require 'cgi'
require 'capybara/poltergeist'
require 'phantomjs/poltergeist'
end

def google arg
  $b = Capybara::Session.new :poltergeist
  $b.visit "http://google.com/search?q=#{arg}"
  Nokogiri.parse($b.body).css("a").map {|e| e[:href]}.grep(/^\/url\?q=/).map {|e| e[/.*?(http.*?)&.*/, 1]}.uniq.
    reject {|url| url[/webcache.google/] || url[/pdf$/]}
end

def wread url
  #$b.visit url
  #$b.body
  html = Boilerpipe.extract url, output: :html
end

def print_snippet url
  url = url[/^http/] ? url : "http://" + url

  dir = File.join(File.dirname($0),'cache-boilerpipe')

  file_name = File.join(dir, CGI.escape(url))
  page = if File.exists? file_name
           File.read file_name
         else
           wread(url).tap {|text|
             File.write file_name, text }
         end

  text = Nokogiri.parse(page).text.split("\n").map(&:rstrip).reject {|line| line[/boilerpipe-mark/]}.
    join("\n").tap {|e| 10.times { e.gsub!("\n\n\n","\n\n")}}

  classifier = Classifier::Bayes.new 'text', 'code'

  def classifier.read_text dir_glob
    Dir[dir_glob].each do |file|
      File.readlines(file).each do |line|
        self.train_text line
      end
    end
  end
  def classifier.read_code dir_glob
    Dir[dir_glob].each do |file|
      File.readlines(file).each do |line|
        self.train_code line
      end
    end
  end

  if false and (File.exists? File.join(dir, 'classifier.dump'))
    classifier = Marshal.load File.read(File.join(dir, 'classifier.dump'))
  else
    classifier.read_code "/home/valt/workspace/GlobalATI/app/**/**.rb"
    classifier.read_text "/home/valt/bin/words2.txt"
    #File.write File.join(dir, 'classifier.dump'), Marshal.dump(classifier)
  end

  confidence = 0.55
  r = text.lines.map{|e| c = classifier.classifications(e);
                      [(c["Code"]+c["Text"] == 0) ? confidence : (c["Text"]/(c["Code"]+c["Text"])), e]}

  puts r.select.with_index {|e,i| r[i][0] >= confidence && (r[i+1].try{|e| e[0] >= confidence} || true) }.map{|e| e[1]}.
    join.tap {|e| 10.times { e.gsub!("\n\n\n","\n\n")}}
end

google(ARGV[0])[0..4].each {|url| puts url+"\n\n"; print_snippet url; puts "\n\n-----------------------\n\n" }
