module ReservationHelper

  def generate_pagination_links_list(start_date, end_date, reservation_total)
    start_date = start_date != nil ? Date.strptime(start_date, '%m/%d/%Y') : (Date.today - 30.days)
    start_date = start_date.strftime('%m/%d/%Y')
    end_date = end_date != nil ? Date.strptime(end_date, '%m/%d/%Y') : Date.today
    end_date = end_date.strftime('%m/%d/%Y')

    links = []
    number_of_links = (reservation_total.to_f / 25).ceil

    Rails.logger.info "Number: #{number_of_links.inspect}"

    from = 0
    (1..number_of_links).to_a.each do |number|
      from = from + 1
      to = number * 25
      links.append admin_reservations_path(start_date: start_date, end_date: end_date, from: from, to: to)
      from = to
    end

    Rails.logger.info "Links: #{links.inspect}"
    return links
  end

end
