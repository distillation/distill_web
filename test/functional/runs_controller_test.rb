require 'test_helper'

class RunsControllerTest < ActionController::TestCase
  setup do
    @run = runs(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:runs)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create run" do
    assert_difference('Run.count') do
      post :create, :run => { :distill_compile_time => @run.distill_compile_time, :distill_size => @run.distill_size, :ghc_compile_time => @run.ghc_compile_time, :ghc_size => @run.ghc_size, :program_id => @run.program_id, :super_compile_time => @run.super_compile_time, :super_size => @run.super_size, :user_id => @run.user_id }
    end

    assert_redirected_to run_path(assigns(:run))
  end

  test "should show run" do
    get :show, :id => @run
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @run
    assert_response :success
  end

  test "should update run" do
    put :update, :id => @run, :run => { :distill_compile_time => @run.distill_compile_time, :distill_size => @run.distill_size, :ghc_compile_time => @run.ghc_compile_time, :ghc_size => @run.ghc_size, :program_id => @run.program_id, :super_compile_time => @run.super_compile_time, :super_size => @run.super_size, :user_id => @run.user_id }
    assert_redirected_to run_path(assigns(:run))
  end

  test "should destroy run" do
    assert_difference('Run.count', -1) do
      delete :destroy, :id => @run
    end

    assert_redirected_to runs_path
  end
end
