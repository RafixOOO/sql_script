UPDATE user_tasks SET ut_state = 'Nowe'
WHERE ut_entity_type = 'contractors-requests' and ut_deleted is false and ut_state = 'Wykonane'