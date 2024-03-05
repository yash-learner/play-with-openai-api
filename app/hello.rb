require 'openai'
require 'dotenv/load'

# Load the .env file
Dotenv.load('../.env')

client = OpenAI::Client.new(access_token: ENV.fetch('OPENAI_API_KEY'))


def add_two_numbers_function
  {
    type: "function",
    function:{
      "name": "add_two_numbers",
      "description": "Adds two numbers together",
      "parameters": {
        "type": "object",
        "properties": {
          "number1": {
            "type": "string",
            "description": "The first number to add"
          },
          "number2": {
            "type": "number",
            "description": "The second number to add"
          }
        },
        "required": ["number1", "number2"]
      }
    }
  }.to_hash
end

def create_feedback_function
  {
    type: "function",
    function:{
      "name": "create_feedback",
      "description": "Creates feedback for a student submission",
      "parameters": {
        "type": "object",
        "properties": {
          "feedback": {
            "type": "string",
            "description": "The feedback to be added to a student submission"
          }
        },
        "required": ["feedback"]
      }
    }
  }
end

def create_grading_function
  {
    type: "function",
    function: {
      name: "create_grading",
      description: "Creates grading for a student submission",
      parameters: {
        type: "object",
        properties: {
          status: {
            type: "string",
            enum: ["accepted", "rejected"]
          },
          feedback: {
            type: "string",
            description: "The feedback to be added to a student submission"
          },
          grades: {
            type: "array",
            items: {
              type: "object",
              properties: {
                evaluationCriterionId: {
                  type: "string",
                  enum: Submission.new.evaluation_criteria_ids,
                },
                grade: {
                  type: "integer",
                  description: "The grade value choosen from available grades for a evaluatuionCriterionID"
                }
              },
              required: ["evaluationCriterionId", "grade"]
            }
          }
        },
        required: ["status", "feedback", "grades"]
      }
    }
  }
end

response = client.chat(
  parameters: {
    model: 'gpt-3.5-turbo',
    messages: [
      { role: 'system', content: 'You are a helpful assistant. That can answer any question best of your ability.' },
      # { role: 'user', content: 'The user wants to add five and six' },
      { role: 'user', content: 'Add some feedback 5+4=9' },
    ],
    tools: [
      # {
      #   type: "function",
      #   function:{
      #     "name": "add_two_numbers",
      #     "description": "Adds two numbers together",
      #     "parameters": {
      #       "type": "object",
      #       "properties": {
      #         "number1": {
      #           "type": "number",
      #           "description": "The first number to add"
      #         },
      #         "number2": {
      #           "type": "number",
      #           "description": "The second number to add"
      #         }
      #       },
      #       "required": ["number1", "number2"]
      #     }
      #   }
      # }
      # add_two_numbers_function
      create_feedback_function
    ]
  }
)

puts response

# tool_calls = response["choices"].first["message"]["tool_calls"]

# puts JSON.parse(tool_calls.first["function"]["arguments"])

arguments_json = response.dig("choices", 0, "message", "tool_calls", 0, "function", "arguments")

puts JSON.parse(arguments_json)
puts
puts JSON.parse(arguments_json).class
puts
arguments = JSON.parse(arguments_json)
puts arguments["feedback"]



# puts create_feedback_function

# puts

# puts create_feedback_function.to_json
