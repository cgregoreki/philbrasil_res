class ContactsController < ApplicationController
  def new
    @contact = Contact.new
    @active_menu = "contact"
    @active_page_title = "Contato"

    render layout: "application"
  end

  def create
    @contact = Contact.new(contact_params)    
    if @contact.valid?
      ContactMailer.new_message(@contact).deliver
      redirect_to contact_path, notice: "Your messages has been sent."
    else
      flash[:alert] = "An error occurred while delivering this message."
      render :new
    end
  end

private

  def contact_params
    params.require(:contact).permit(:name, :email, :message)
  end

end
