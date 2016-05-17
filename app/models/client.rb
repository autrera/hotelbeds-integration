class Client < ActiveRecord::Base

  has_many :reservations

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable,
         :recoverable, :rememberable, :trackable, :validatable

  default_scope {
    order id: :asc
  }

  after_create :send_client_credentials

  private

    def send_client_credentials
      password = (0...8).map { (65 + rand(26)).chr }.join
      self.password = password
      self.save
      # ClientMailer.login_credentials(self, password)
    end

end
