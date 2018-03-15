class ChangeRecipeIngredientsQuantityDataType < ActiveRecord::Migration[5.1]
  def change
    change_column :recipe_ingredients, :quantity, :string
  end
end
