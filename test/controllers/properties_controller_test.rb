require "test_helper"

class PropertiesControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get properties_index_url
    assert_response :success
  end

  test "should get new" do
    get properties_new_url
    assert_response :success
  end

  test "should get create" do
    get properties_create_url
    assert_response :success
  end

  test "should get show" do
    get properties_show_url
    assert_response :success
  end
end
