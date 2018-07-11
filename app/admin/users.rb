ActiveAdmin.register User do
  permit_params :email, :password, :password_confirmation

  index do
    id_column
    column :email
    column :current_sign_in_at
    column :last_sign_in_at
  end

  form do |f|
    f.inputs :email, :password, :password_confirmation
    f.actions
  end
end
