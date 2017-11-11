require "tilt/erubis"
require "sinatra"
require "sinatra/reloader"

def each_chapter(&block)
  @contents.each_with_index do |name, index|
    number = index + 1
    contents = File.read("data/chp#{number}.txt")
    yield(name, number, contents)
  end
end

def chapters_matching(query)
  results = []

  return results unless query

  each_chapter do |name, number, contents|
    matches = {}
    contents.split("\n\n").each_with_index do |paragraph, index|
      matches[index] = paragraph if paragraph.include?(query)
    end
    results << {number: number, name: name, paragraphs: matches} if matches.any?
  end

  results
end

before do
  @contents = File.readlines("data/toc.txt")
end

helpers do
  def in_paragraphs(text)
    text.split(/\n{2}/).map.with_index do |paragraph, index|
      "<p id=paragraph#{index}>#{paragraph}</p>"
    end.join
  end

  def highlight(text, term)
    text.gsub(term, %(<strong>#{term}</strong>))
  end
end

not_found do
  redirect "/"
end

get "/" do
  @title = "シャーロック・ホームズの冒険"

  erb :home
end

get "/chapters/:number" do
  chp_num = params[:number].to_i
  chp_name = @contents[chp_num - 1]

  redirect "/" unless (1..@contents.size).cover?(chp_num)

  @title = "Chapter #{chp_num}: #{chp_name}"
  @chapter = File.read("data/chp#{params[:number]}.txt")

  erb :chapter
end

get "/search" do
  @title = "Search"
  @matches = chapters_matching(params[:query])
  erb :search
end
