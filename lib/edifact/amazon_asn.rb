module EDIFACT
    class Interchange
        def is_amazon_asn?
            valid = true
            for message in messages do
                # Assert message is DESADV
                return false unless message.is_a?(DESADVMessage)
                # Either bill of lading or delivery quote must be included
                bill_of_lading = message.bill_of_lading
                delivery_quote = message.delivery_quote
                valid = false if bill_of_lading.blank? && delivery_quote.blank?
                # Shipment ID/ASN ID must be included
                valid = false if message.asn_id.blank?
                # Shipped date must be included
                valid = false if message.shipped_date.blank?
                # Delivery date must be included
                valid = false if message.delivery_date.blank?
                # Carton count must be included
                valid = false if message.carton_count.blank?
                # Pallet count must be included
                valid = false if message.pallet_count.blank?
                # Ship to must be included and valid GLN
                ship_to = message.ship_to&.value
                valid = false if ship_to.blank?
                valid = false unless ship_to&.is_gln?
                # Supplier ID must be included and valid GLN
                supplier_id = message.supplier_id&.value
                valid = false if supplier_id.blank?
                valid = false unless supplier_id&.is_gln?
                # Ship from must be included and valid GLN
                ship_from = message.ship_from&.value
                valid = false if ship_from.blank?
                valid = false unless ship_from&.is_gln?
                # PO number must be included
                valid = false if message.po_number.blank?
            end
            return valid
        end
    end
end