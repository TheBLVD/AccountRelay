require "test_helper"

class Api::V1::ChannelsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get api_v1_channels_index_url
    assert_response :success
  end

  test "should get show" do
    get api_v1_channels_show_url
    assert_response :success
  end

  test "should get new" do
    get api_v1_channels_new_url
    assert_response :success
  end

  test "should get destory" do
    get api_v1_channels_destory_url
    assert_response :success
  end
end
