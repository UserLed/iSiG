class Givers::SessionsController < ApplicationController
  before_filter :require_login

  def index
    @giver = Giver.find(params[:giver_id])
  end
  
  def personal_details
    @giver = Giver.find(params[:giver_id])

    if request.post?
      @giver.update_attributes(session_method: params[:session_method],
        skype_id: params[:skype_id],
        contact_number: params[:contact_number],
        other_contact_details: params[:other_contact_details],
        user_time_zone: params[:user_time_zone][:time_zone])
      redirect_to giver_sessions_path(current_user), :notice => "Personal details have been updated"

      #render :json => params.inspect + @giver.inspect
      return

    end
  end

  def manage_requests
    @giver = Giver.find(params[:giver_id])
  end

  def inbox
    @giver = Giver.find(params[:giver_id])
  end

  def inbox
  	@messages= Message.where("from_id=? OR to_id=?", current_user.id, current_user.id)
  	@messages_count = @messages.count
  	@messages = @messages.group("uid")
  end

  def new_message
  	require 'securerandom'

  	@to = User.find(params[:giver_id])   #might also be seeker_id
  	
  	if request.post?
  		message = Message.new

  		message.from = params[:from] if params[:from].present?
  		message.from_id = current_user.id

  		message.to = params[:to] if params[:to].present?
  		message.to_id= @to.id

  		message.subject = params[:subject] if params[:subject].present?
  		message.content = params[:content] if params[:content].present?

  		message.uid = SecureRandom.uuid
  	
  	
	  	if message.save
	  		redirect_to inbox_giver_sessions_path(current_user), :notice => "message was sent successfully"
	  		return
	  	else
	  		render 'new_message'
	  	end
    end

  end


  def show_message
  	@messages = Message.where('uid=?',params[:uid])
  	
  	if request.post?
  		message = @messages.first
  		reply = Message.new
  		
  		reply.from = current_user.email
  		reply.from_id = current_user.id

  		reply.to =  (current_user.email.eql?(message.from)) ? message.to : message.from
  		reply.to_id = (current_user.id.eql?(message.from_id)) ? message.to_id : message.from_id

  		reply.subject = message.subject
  		reply.content = params[:content] if params[:content].present?

  		reply.uid = message.uid

  		if reply.save
  			redirect_to inbox_giver_sessions_path(current_user), :notice => "Reply was successful"
  			return
  		else
  			render 'show_message'
  		end
  	end
  end


  def time_slot_save

  	existing_time_slots = current_user.time_slots
  	unless existing_time_slots.blank?
  		existing_time_slots.destroy_all
  	end
  	time_slots = params[:time_slots]
  	unless time_slots.nil?
	  	time_slots = time_slots.collect{|slot| slot.split("_")}
	  	
	  	time_slots.each do |slot|
	  		tmp_slot = TimeSlot.new
	  		tmp_slot.giver_id = current_user.id
	  		tmp_slot.day = slot[0]
	  		tmp_slot.time = slot[1]
	  		tmp_slot.time_format = slot[2]
	  		tmp_slot.save
	  	end

	  	render :nothing => true
	  	return
	  end
	  render :nothing => true
	end

	
end
