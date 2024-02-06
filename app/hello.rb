require 'openai'
require 'dotenv/load'

# Load the .env file
Dotenv.load('../.env')

client = OpenAI::Client.new(access_token: ENV.fetch('OPENAI_API_KEY'))

response = client.chat(
  parameters: {
    model: 'gpt-3.5-turbo',
    messages: [
      { role: 'system', content: 'You are a helpful assistant. That can answer any question best of your ability.' },
      { role: 'user', content: 'Hello!' },
  ],
  }
)

puts response
