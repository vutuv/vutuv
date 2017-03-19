defmodule Vutuv.CouponTest do
  use Vutuv.ModelCase

  alias Vutuv.Coupon

  @valid_attrs %{amount: "120.5", code: "some content", ends_on: %{day: 17, month: 4, year: 2010}, percentage: 42, user_id: 42}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Coupon.changeset(%Coupon{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Coupon.changeset(%Coupon{}, @invalid_attrs)
    refute changeset.valid?
  end
end
