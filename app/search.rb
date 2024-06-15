require 'openai'
require 'dotenv/load'
require "langchain"
require "hnswlib"

# Load the .env file
Dotenv.load('../.env')

# client = OpenAI::Client.new(access_token: ENV.fetch('OPENAI_API_KEY'))

openai_api_key = ENV['OPENAI_API_KEY']


class Document
  attr_accessor :content, :metadata

  def initialize(content:, metadata: {})
    @content = content
    @metadata = metadata
  end
end



movies = [
  {
    id: 1,
    title: 'Stepbrother',
    description: "Comedic journey full of adult humor and awkwardness.",
  },
  {
    id: 2,
    title: 'The Matrix',
    description: "Deals with alternate realities and questioning what's real.",
  },
  {
    id: 3,
    title: 'Shutter Island',
    description: "A mind-bending plot with twists and turns.",
  },
  {
    id: 4,
    title: 'Memento',
    description: "A non-linear narrative that challenges the viewer's perception.",
  },
  {
    id: 5,
    title: 'Doctor Strange',
    description: "Features alternate dimensions and reality manipulation.",
  },
  {
    id: 6,
    title: 'Paw Patrol',
    description: "Children's animated movie where a group of adorable puppies save people from all sorts of emergencies.",
  },
  {
    id: 7,
    title: 'Interstellar',
    description: "Features futuristic space travel with high stakes",
  },
]


# puts Document.new(content: "This is a sample document.")

embeddings = Langchain::LLM::OpenAI.new(api_key: openai_api_key)

vector_search = Langchain::Vectorsearch::Hnswlib.new(llm: embeddings, path_to_index: 'index.ann')

puts embeddings

puts vector_search


# Create documents and add to vector store
def add_movies_to_store(movies, vector_search, embeddings)
  texts = []
  ids = []

  movies.each do |movie|
    content = "Title: #{movie[:title]}\n#{movie[:description]}"
    metadata = { source: movie[:id], title: movie[:title] }
    document = Document.new(content: content, metadata: metadata)

    texts << document.content
    ids << movie[:id]
  end

  vector_search.add_texts(texts: texts, ids: ids)
end

r = add_movies_to_store(movies, vector_search, embeddings)

puts r


# Perform a similarity search
def search(query, count = 1, vector_search, embeddings)
  results = vector_search.similarity_search(query: query, k: count)
  puts "inside"
  puts results.inspect
  ids = results[0]
  distances = results[1]

  ids.map.with_index do |id, index|
    {
      id: id,
      distance: distances[index]
    }
  end
end

# Example query
# query = "something cute and fluffy"
query = "A movie that will make me feel crazy"
results = search(query, 2, vector_search, embeddings)

puts results
