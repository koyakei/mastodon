class KTagAddRelationRequestsController < ApplicationController
  include Authorization

  before_action :authenticate_user!
  before_action :set_k_tag_add_relation_request, only: %i[ show edit update destroy ]

  # GET /k_tag_add_relation_requests
  def index
    @k_tag_add_relation_requests = KTagAddRelationRequest.all
  end

  # GET /k_tag_add_relation_requests/1
  def show
    @k_tag_add_relation_request.destroy!
  end

  # GET /k_tag_add_relation_requests/new
  def new
    @k_tag_add_relation_request = KTagAddRelationRequest.new
  end

  # GET /k_tag_add_relation_requests/1/edit
  def edit
  end

  # POST /k_tag_add_relation_requests
  def create
    @k_tag_add_relation_request = KTagAddRelationRequest.new(k_tag_add_relation_request_params)

    if @k_tag_add_relation_request.save
      redirect_to @k_tag_add_relation_request, notice: "K tag add relation request was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /k_tag_add_relation_requests/1
  def update
    if @k_tag_add_relation_request.update(k_tag_add_relation_request_params)
      redirect_to @k_tag_add_relation_request, notice: "K tag add relation request was successfully updated.", status: :see_other
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /k_tag_add_relation_requests/1
  def destroy
    @k_tag_add_relation_request.destroy!
    redirect_to k_tag_add_relation_requests_url, notice: "K tag add relation request was successfully destroyed.", status: :see_other
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_k_tag_add_relation_request
      @k_tag_add_relation_request = KTagAddRelationRequest.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def k_tag_add_relation_request_params
      params.fetch(:k_tag_add_relation_request, {})
    end
end
