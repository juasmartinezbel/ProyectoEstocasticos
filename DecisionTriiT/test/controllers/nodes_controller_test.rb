require 'test_helper'

class NodesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @node = nodes(:one)
  end

  test "should get index" do
    get nodes_url, as: :json
    assert_response :success
  end

  test "should create node" do
    assert_difference('Node.count') do
      post nodes_url, params: { node: { children: @node.children, expected_value: @node.expected_value, gain: @node.gain, ide: @node.ide, name: @node.name, parent: @node.parent, probability: @node.probability, route: @node.route } }, as: :json
    end

    assert_response 201
  end

  test "should show node" do
    get node_url(@node), as: :json
    assert_response :success
  end

  test "should update node" do
    patch node_url(@node), params: { node: { children: @node.children, expected_value: @node.expected_value, gain: @node.gain, ide: @node.ide, name: @node.name, parent: @node.parent, probability: @node.probability, route: @node.route } }, as: :json
    assert_response 200
  end

  test "should destroy node" do
    assert_difference('Node.count', -1) do
      delete node_url(@node), as: :json
    end

    assert_response 204
  end
end
