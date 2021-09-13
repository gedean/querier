# Active Record Querier

> class UserQuerier < Querier
> > @active_record_class = ApplicationRecord  
def initialize user_name:, active:  
> > > @query_template = "SELECT * FROM users WHERE   name = ${user_name} AND active = ${active/no_quote}"  
super
> > 
> > end
> > 
> end

> UserQuerier.new(user_name: 'foo', active: true).select_all.to_struct
