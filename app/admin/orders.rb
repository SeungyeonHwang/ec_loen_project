ActiveAdmin.register Order do

  scope :all

  # enumのステータスを持ってくるコード
  scope -> {"決済 前"}, :before_payment
  scope -> {"決済 済"}, :processing
  scope -> {"配達 完了"}, :completed
  scope -> {"キャンセル"}, :order_failed
  scope -> {"返金 済"}, :canceled

  # フィルター整理
  filter :name
  filter :phone
  filter :post_code
  filter :address
  filter :email
  # Order以外のテーブルから絞り込む_ransack(table_column_[eq/cont])
  filter :user_email_cont, label: "ユーザーEメールで検索"
  filter :cosmetics_product_name_cont, label: "商品名で検索"

  batch_action :canceled, form: {
    cancel_reason: :textarea
  } do |ids, inputs|
    orders = Order.where(id: ids)
    orders.each do |order|
      #返金の内部ロジック

      order.update(cancel_reason: inputs["cancel_reason"], status: :canceled)
    end
    flash[:notice] = "返金されました。"
    redirect_to collection_path
  end

  index do
    selectable_column
    id_column
    column :user do |order|
      a order.user.email, href: "/admin/users/#{order.user.id}"
    end
    column :address
    column :email
    column :name
    column :phone
    column :postal_code
    column :status
    column :created_at
    actions
  end

  show do
    attributes_table do
      row :address
      row :email
      row :name
      row :phone
      row :postal_code
      row :status
    end

    # data-dense page (Documentation)
    panel "注文情報" do
      table_for order.order_items do
        column "商品名" do |item|
          item.cosmetic.product_name
        end
        column "数量" do |item|
          item.quantity
        end
        column "単価" do |item|
          number_to_currency(item.cosmetic.price)
        end
        column "合計" do |item|
          number_to_currency(item.cosmetic.price * item.quantity)
        end
        column "リンク" do |item|
          a "詳細", href: "/admin/cosmetics/#{item.cosmetic.id}", target: "_blank"
        end
        if order.canceled?
          column "返金の理由" do |item|
            item.order.cancel_reason
          end
        end
      end
    end

  end

  # SideBar修正
  sidebar "決済情報", only: :show do
    attributes_table_for order.payment do
      row :amount do |payment|
        number_to_currency(payment.amount)
      end
      row :merchant_id
      row :payer_id
      row :payment_uid
      # row :response
      row "リンク" do |payment|
        a "領収書等", href: "https://www.sandbox.paypal.com/myaccount/home", target: "_blank"
      end
    end
  end
end
