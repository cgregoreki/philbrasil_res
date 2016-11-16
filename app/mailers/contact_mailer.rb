class ContactMailer < ApplicationMailer
    default from: "PhilBrasil <noreply@philbrasil.com.br>"
    default to: "PhilBrasil Contact Form <the_destination_email@philbrasil.com>"

    def new_message(contact)
        @contact = contact

        mail subject: "Message from #{contact.name}"
    end


end
