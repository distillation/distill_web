require 'test_helper'

class TimingsControllerTest < ActionController::TestCase
  setup do
    @timing = timings(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:timings)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create timing" do
    assert_difference('Timing.count') do
      post :create, :timing => { :distill_02_time => @timing.distill_02_time, :distill_O2_compile => @timing.distill_O2_compile, :distill_O2_mem => @timing.distill_O2_mem, :distill_compile => @timing.distill_compile, :distill_mem => @timing.distill_mem, :distill_time => @timing.distill_time, :normal_O2_compile => @timing.normal_O2_compile, :normal_O2_mem => @timing.normal_O2_mem, :normal_O2_time => @timing.normal_O2_time, :normal_compile => @timing.normal_compile, :normal_mem => @timing.normal_mem, :normal_time => @timing.normal_time, :program_id => @timing.program_id, :super_O2_compile => @timing.super_O2_compile, :super_O2_mem => @timing.super_O2_mem, :super_O2_time => @timing.super_O2_time, :super_compile => @timing.super_compile, :super_mem => @timing.super_mem, :super_time => @timing.super_time }
    end

    assert_redirected_to timing_path(assigns(:timing))
  end

  test "should show timing" do
    get :show, :id => @timing
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @timing
    assert_response :success
  end

  test "should update timing" do
    put :update, :id => @timing, :timing => { :distill_02_time => @timing.distill_02_time, :distill_O2_compile => @timing.distill_O2_compile, :distill_O2_mem => @timing.distill_O2_mem, :distill_compile => @timing.distill_compile, :distill_mem => @timing.distill_mem, :distill_time => @timing.distill_time, :normal_O2_compile => @timing.normal_O2_compile, :normal_O2_mem => @timing.normal_O2_mem, :normal_O2_time => @timing.normal_O2_time, :normal_compile => @timing.normal_compile, :normal_mem => @timing.normal_mem, :normal_time => @timing.normal_time, :program_id => @timing.program_id, :super_O2_compile => @timing.super_O2_compile, :super_O2_mem => @timing.super_O2_mem, :super_O2_time => @timing.super_O2_time, :super_compile => @timing.super_compile, :super_mem => @timing.super_mem, :super_time => @timing.super_time }
    assert_redirected_to timing_path(assigns(:timing))
  end

  test "should destroy timing" do
    assert_difference('Timing.count', -1) do
      delete :destroy, :id => @timing
    end

    assert_redirected_to timings_path
  end
end
