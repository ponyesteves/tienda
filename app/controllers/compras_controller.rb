class ComprasController < ApplicationController
	before_action :set_compra, only: [:show, :update, :destroy]
	
	def index
		@compras = Operacion.compras.order(:created_at).as_json
	
		respond_to do |format|
			format.json	{render json: @compras.as_json}
			format.csv { 
				send_data Operacion.exportar('compra').to_csv_compras }
		end
	end

	def show
		render json: @compra.as_json
	end
	
	def create
		op_compra = Operaciontipo.find_by_nombre('compra')
		compra = op_compra.operaciones.new(compra_params)
		if compra.save
			head :no_content
		else
			render json: compra.errors.full_messages.to_json, status: 422
		end
	end

	def update
		if @compra.update(compra_params)
			head :no_content
		end
	end

	def destroy
		if @compra.destroy
			head :no_content
		end
	end

private

	def set_compra
		@compra = Operacion.find(params[:id])
	end

	def compra_params
		# unless params[:operacion][:organizacion].blank?
		# 	params[:operacion][:organizacion_id] = params[:operacion][:organizacion][:id]
		# 	params[:operacion].delete("organizacion")
		# end
		unless params[:compra][:operacionitems].blank?
			params[:compra][:operacionitems_attributes] = params[:compra][:operacionitems]
			params[:compra].delete("operacionitems")
			params[:compra][:operacionitems_attributes].each do |item|
				item[:producto_id] = item[:producto][:id]
				item.delete("producto")
			end
		end
		params.require(:compra).permit(:fecha, :desc, :operaciontipo_id, :organizacion_id, :total,
			operacionitems_attributes: [:id, :producto_id, :cantidad, :precio, :_destroy])
	end

end