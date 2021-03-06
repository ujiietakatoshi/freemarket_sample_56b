class ItemsController < ApplicationController

  #mishima ユーザー新規登録 deviseの機能を追加
  before_action :authenticate_user!,except: [:index,:toppage]
  before_action :set_item,except: [:new,:toppage,:create,:get_category_children,:get_category_grandchildren]

  def new
    #セレクトボックスの初期値設定  
    @category_parent_array = Category.where(ancestry: nil).pluck(:name)
    @category_parent_array.unshift("---")
    @items = Item.new
    @items.images.build
    @prefectures = Prefecture.all
    sell1=Item.last(1)
    if sell1.present?
      sell1.each do |sell|
      @sell = sell.id+1
      end
      else
      @sell = 1
    end
  end

  def edit
    @images = @item.images
    @category_parent_array = Category.where(ancestry: nil).pluck(:name)
    @category_parent_array.unshift("---")
    @items = Item.new
    @items.images.build
    @prefectures = Prefecture.all
    @category = Category.find(@item.category_id)
    @category_1 = @category.name
    @category_2 = @category.parent.id
    @category_3 = @category.root.id  
    @category_children = Category.where(ancestry: @category_3)
    @category_grandchildren = Category.where(ancestry:"#{@category_3}/#{@category_2}")
    @sell = @item.id

    # 氏家他人の編集した物のlinkを直打ちしたらtoppageに飛ばす記載を追加
    if @item.seller_id != current_user.id
      redirect_to root_path
    else
    end
  end
  
  def update
    if @item.seller_id != current_user.id
      redirect_to root_path
    else
    end

    if !(@item.update(edit_item_params))
      redirect_to edit_item_path(@item.id)
    end

  end

  # sakaguchi トップページにDBからデータを取り出す記述を追加
  def toppage
    @items = Item.order("created_at DESC").limit(10)
  end

  def get_category_children
    #選択された親カテゴリーに紐付く子カテゴリーの配列を取得
    @category_children = Category.find_by(name: "#{params[:parent_name]}", ancestry: nil).children
  end

  def get_category_grandchildren
  #選択された子カテゴリーに紐付く孫カテゴリーの配列を取得
    @category_grandchildren = Category.find("#{params[:child_id]}").children
  end

  def create
    @items = Item.new(item_params)
    if @items.save  
    else
      @prefectures = Prefecture.all
      @category_parent_array = Category.where(ancestry: nil).pluck(:name)
      @category_parent_array.unshift("---")
      render :new
    end
  end

  def show
    @images = Image.where(item_id: @item)
    @user = User.find_by(id: @item.seller_id)
    @items = Item.where(seller_id:@user.id).order("created_at DESC").limit(6)
    @category = Category.find(@item.category_id)
  end
  
  # ujiie 購入機能に必要なアクションを追記
  require 'payjp'

  def purchase
    @item = Item.find(params[:id])
    @images = Image.where(item_id: @item)
    user_id = Seller.find_by(item_id: @item)
    @user = User.find_by(id: user_id)
    card = Card.where(user_id: current_user.id).first

    # 氏家購入した物のlinkを直打ちしたらtoppageに飛ばす記載を追加
    buyer_id = Item.find(params[:id])
    if @item.buyer_id
      redirect_to root_path
    else
    end

    # 自分の出品した物を購入しようとしたらtoppageに飛ばす記載を追加
    if @item.seller_id == current_user.id
      redirect_to root_path
    else
    end

    if card.present?
      Payjp.api_key= "sk_test_3c6c6f094d2e40b7a314b6c3"
      customer = Payjp::Customer.retrieve(card.customer_id)
      @default_card_information = customer.cards.retrieve(card.card_id)
    else
    end
end
    
 

  def buy
    card = current_user.card
    if card.blank?
      redirect_to controller: "card", action: "new"
      # カード情報が登録されていなかったら登録画面に遷移する
    else
      Payjp.api_key= "sk_test_3c6c6f094d2e40b7a314b6c3"
      Payjp::Charge.create(
      amount: @item.price, #支払金額
      customer: card.customer_id, #顧客ID
      currency: 'jpy', #日本円
      )
      @item.buyer_id = current_user.id
      @item.save
  redirect_to action: 'done' #完了画面に移動
  end
end

  def done
    if @item.buyer_id != current_user.id
      redirect_to root_path
    else
    end
  end

  # sakaguchi 商品の削除機能
  def destroy
      item = Item.find(params[:id])
      if item.seller_id != current_user.id
        redirect_to root_path
      elsif item.destroy 
         flash[:notice] = "商品を削除しました"
         redirect_to root_path
      else
        flash[:alert] = "商品を削除できませんでした"
        redirect_to root_path
      end

  end

  private
  
  def item_params
    params.require(:item).permit(:name,:description,:category_id,:size,:brand,:status,:ship_person,:ship_method,:ship_area,:ship_days,:price,images_attributes: [:image]).merge(seller_id: current_user.id)
  end

  def edit_item_params
    params.require(:item).permit(:name,:description,:category_id,:size,:brand,:status,:ship_person,:ship_method,:ship_area,:ship_days,:price,images_attributes: [:id, :image]).merge(seller_id: current_user.id)
  end

  def set_item
    @item = Item.find(params[:id])
  end
end