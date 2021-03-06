class VentasController < ApplicationController
	before_action :set_venta, only: [:show, :update, :destroy]

	def index
		@ventas = Operacion.ventas.order(:created_at)
	
		respond_to do |format|
			format.json	{render json: @ventas.as_json}
			format.csv { send_data  Operacion.exportar('venta').to_csv_ventas }
		end

	end

	def show
		render json: @venta.as_json
	end
	
	def create
		op_venta = Operaciontipo.find_by_nombre('venta')
		venta = op_venta.operaciones.new(venta_params)
		if venta.save
			head :no_content
		else
			render json: venta.errors.full_messages.to_json, status: 422
		end
	end

	def update
		if @venta.update(venta_params)
			head :no_content
		end
	end

	def destroy
		if @venta.destroy
			head :no_content
		end
	end



private

	def set_venta
		@venta = Operacion.find(params[:id])
	end

	def venta_params
		unless params[:venta][:operacionitems].blank?
			params[:venta][:operacionitems_attributes] = params[:venta][:operacionitems]
			params[:venta].delete("operacionitems")
			params[:venta][:operacionitems_attributes].each do |item|
				item[:producto_id] = item[:producto][:id]
				item.delete("producto")
			end
		end
		# if params[:venta][:pagotipo]
		# 	params[:venta][:pagotipo_id] = params[:venta][:pagotipo][:id]
		# 	params[:venta].delete("pagotipo")
		# end

		params.require(:venta).permit(:fecha, :desc, :total, :pago, :operaciontipo_id, :pagotipo_id, operacionitems_attributes: [:id, :producto_id, :cantidad, :precio, :_destroy])
	end

end