
component restPath="/todos" rest="true" {
    variables.dataSource = "cf_learning";

    remote array function getTodos() httpmethod="GET" restpath="" {
        var sql = "SELECT * FROM todo";
        var result = queryExecute(sql, [], {dataSource = variables.dataSource});
        
        var todos = [];
        
        for (var i = 1; i <= result.recordCount; i++) {
            var todo = structNew("ordered");

            todo["id"] = result.id[i];
            todo["name"] = result.name[i];
            todo["description"] = result.description[i];
            todo["status"] = result.status[i];
            todo["priority"] = result.priority[i];
            todo["due_date"] = result.due_date[i];

            arrayAppend(todos, todo);
        }
                
        return todos;

    }

    remote struct function getTodo(required string id restargsource="Path") httpmethod="GET" restpath="{id}" {

        if (len(trim(arguments.id)) == 0) {
            cfheader(statuscode="400", statustext="Bad Request");
            return {"error" = "No ID provided."};
        }
        
        var sql = "SELECT * FROM todo WHERE id = ?";
        var result = queryExecute(sql, [arguments.id], {dataSource = variables.dataSource});
    
        if (result.recordCount == 0){
            cfheader(statuscode="404", statustext="Not Found");
            return {"error" = "Todo with id: #arguments.id# not found."};
        }
        

        var todo = structNew("ordered");
        todo["id"] = result.id[1];
        todo["name"] = result.name[1];
        todo["description"] = result.description[1];
        todo["status"] = result.status[1];
        todo["priority"] = result.priority[1];
        todo["due_date"] = result.due_date[1];
        
        return todo;
    }


    remote struct function createTodo() httpmethod="POST" restpath="" {
        var requestData = getHttpRequestData();
        var newTodo = deserializeJSON(requestData.content);

        var sql = "
            INSERT INTO todo (name, description, status, priority, due_date) 
            VALUES (?, ?, ?, ?, ?)";
        var result = queryExecute(sql, [
            newTodo.name, 
            newTodo.description, 
            newTodo.status, 
            newTodo.priority, 
            newTodo.due_date
        ], {dataSource = variables.dataSource});
        
        cfheader(statusCode="201", statusText="Created");
        return {"message" = "Todo created successfully."};
        
    }
    
    remote struct function deleteTodo(required string id restargsource="Path") httpmethod="DELETE" restpath="{id}" {

        if (len(trim(arguments.id)) == 0) {
            cfheader(statuscode="400", statustext="Bad Request");
            return {"error" = "No ID provided."};
        }
        
        var sql = "SELECT * FROM todo WHERE id = ?";
        var result = queryExecute(sql, [arguments.id], {dataSource = variables.dataSource});
    
        if (result.recordCount == 0){
            cfheader(statuscode="404", statustext="Not Found");
            return {"error" = "Todo with id: #arguments.id# not found."};
        }

        sql = "DELETE FROM todo WHERE id = ?";
        result = queryExecute(sql, [arguments.id], {dataSource = variables.dataSource});
        
        cfheader(statusCode="200", statusText="Deleted");
        return {"message" = "Todo deleted successfully."};
    }


    remote any function updateTodo(required string id restargsource="Path") httpmethod="PUT" restpath="{id}" {

        if (len(trim(arguments.id)) == 0) {
            cfheader(statuscode="400", statustext="Bad Request");
            return {"error" = "No ID provided."};
        }
        
        var sql = "SELECT * FROM todo WHERE id = ?";
        var result = queryExecute(sql, [arguments.id], {dataSource = variables.dataSource});
    
        if (result.recordCount == 0){
            cfheader(statuscode="404", statustext="Not Found");
            return {"error" = "Todo with id: #arguments.id# not found."};
        }
        
        var requestData = getHttpRequestData();
        
        if (len(trim(requestData.content)) == 0){
            cfheader(statuscode="400", statustext="Bad Request");
            return {"error" = "Content not provided."};
        }
        
        var updatedTodo = deserializeJSON(requestData.content);

        var sql = "
            UPDATE todo 
            SET name = ?, description = ?, status = ?, priority = ?, due_date = ?
            WHERE id = ?";
        var result = queryExecute(sql, [
            updatedTodo.name, 
            updatedTodo.description, 
            updatedTodo.status, 
            updatedTodo.priority, 
            updatedTodo.due_date,
            arguments.id
        ], {dataSource = variables.dataSource});
        
        cfheader(statusCode="200", statusText="Updated");
        return {"message" = "Todo updated successfully."};
    }

}