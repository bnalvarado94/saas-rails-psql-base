# Purpose: Base class for service objects.
# Provides a .call class method so services can be invoked as:
#   MyService.call(args) instead of MyService.new(args).call
#
# Example usage:
#   class Users::CreateService < ApplicationService
#     def initialize(params)
#       @params = params
#     end
#
#     def call
#       User.create!(@params)
#     end
#   end

class ApplicationService
  def self.call(...)
    new(...).call
  end
end
