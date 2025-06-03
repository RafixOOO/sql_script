select usr_name,usr_state, ua_street
from users
inner join user_addresses on ua_user_fkey=usr_id
where ua_street is null and ua_type='RESIDENCE'