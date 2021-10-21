import ballerinax/java.jdbc;
import ballerina/io;


configurable string dbUrl = ?;
configurable string dbUsername = ?;
configurable string dbPassword = ?;

public type Employee record {|
    int id?;
    string first_name;
    string last_name;
    int dept_id;
    string designation;
    int supervisor_id;
|};

public function main() returns error? {
    jdbc:Client dbClient = check new(url = dbUrl, user = dbUsername, password = dbPassword);

    // _ = check dbClient->execute(`DROP DATABASE IF EXISTS test_db`);
    // _ = check dbClient->execute(`CREATE DATABASE test_db`);

    _ = check dbClient->execute(`DROP TABLE IF EXISTS Employees`);
    _ = check dbClient->execute(`
        CREATE TABLE Employees (
            id INT(6) AUTO_INCREMENT PRIMARY KEY,
            first_name VARCHAR(30) NOT NULL,
            last_name VARCHAR(30) NOT NULL,
            dept_id INT(3) NOT NULL,
            designation VARCHAR(30) NOT NULL,
            supervisor_id INT(6) NOT NULL
        )
    `);

    Employee employee = {
        first_name: "Tom",
        last_name: "Scott",
        dept_id: 1,
        designation: "Executive",
        supervisor_id: 1
    };
    _ = check addEmployee(employee);

    Employee retrievedEmployee = check getEmployee(1);
    io:println(retrievedEmployee);

    return;
}

isolated function addEmployee(Employee employee) returns error? {
    jdbc:Client dbClient = check new(url = dbUrl, user = dbUsername, password = dbPassword);
    _ = check dbClient->execute(`
        INSERT INTO Employees (first_name, last_name, dept_id, designation, supervisor_id)
        VALUES (${employee.first_name}, ${employee.last_name}, ${employee.dept_id}, ${employee.designation}, ${employee.supervisor_id})
    `);
}

isolated function getEmployee(int id) returns Employee|error {
    jdbc:Client dbClient = check new(url = dbUrl, user = dbUsername, password = dbPassword);
    Employee employee = check dbClient->queryRow(`SELECT * FROM Employees WHERE id = ${id}`);
    return employee;
}

// public function listEmployees() returns Employee[]|error {
//     int count = check dbClient->queryRow(`SELECT COUNT(*) FROM Employees`);
//     Employee[count] employees = [];
// 
// 
//     stream<Employee, error?> streamData = dbClient->query(`SELECT * FROM Employees`);
//     _ = check streamData.forEach(function(Employee employee) {
//         employees[0] = employee;
//     });
//     return employees;
// }
