# frozen_string_literal: true

class TestsController < SimpleRackFramework::Controller
  before_action :find_test, only: %i[show update destroy]

  def index
    tests = Test.all.map(&:to_json)
    json_response ok(tests)
  end

  def show
    return json_response not_found unless @test

    json_response ok(@test.to_json)
  end

  def create
    test = Test.new(test_params)

    begin
      test.save
      json_response ok(id: test.id)
    rescue Sequel::ValidationFailed
      json_response error(test.errors.full_messages)
    end
  end

  def update
    return json_response not_found unless @test

    begin
      @test.update(test_params)
      json_response ok(@test.to_json)
    rescue Sequel::ValidationFailed
      json_response error(@test.errors.full_messages)
    end
  end

  def destroy
    return json_response not_found unless @test

    @test.destroy
    json_response ok
  end

  private

  def find_test
    @test = Test[params[:id]]
  end

  def test_params
    { title: params[:title], level: params[:level] }.compact
  end

  def json_response(content)
    render json: content
  end

  def ok(result = nil)
    { status: :ok, result: result }.compact
  end

  def not_found
    { status: :not_found }
  end

  def error(msg)
    { status: :internal_error, messages: msg }
  end
end
