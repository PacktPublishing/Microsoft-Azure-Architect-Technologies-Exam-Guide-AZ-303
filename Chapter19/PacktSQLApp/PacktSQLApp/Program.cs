using System;
using System.Data.SqlClient;

namespace PacktSQLApp
{
    class Program
    {
        // The SQL Connection string
        static string connectionstring;
        // The SQL connection
        static SqlConnection connection;

        // Create the employee object
        static Employee NewEmployee = new Employee
        {
            FirstName = "Sjoukje",
            LastName = "Zaal",
            Title = "Mrs",
            BirthDate = new DateTime(1979, 7, 7),
            HireDate = new DateTime(2020, 1, 1)
        };


        static void Main(string[] args)
        {
            try
            {
                Console.WriteLine("Beginning operations...\n");
                GetStartedDemo();

            }
            catch (SqlException de)
            {
                Exception baseException = de.GetBaseException();
                Console.WriteLine("{0} error occurred: {1}", de.Message, de);
            }
            catch (Exception e)
            {
                Console.WriteLine("Error: {0}", e);
            }
            finally
            {
                Console.WriteLine("End of demo, press any key to exit.");
                Console.ReadKey();
            }
        }
        static void GetStartedDemo()
        {
            connectionstring = "<replace-with-your-connectionstring>";

            AddItemsToDatabase();
            QueryItems();
            UpdateEmployeeItem();
            DeleteEmployeeItem();

        }

        static void AddItemsToDatabase()
        {
            connection = new SqlConnection(connectionstring);

            using (connection)
            {
                try
                {
                    Console.WriteLine("\nCreate a new employee:");
                    Console.WriteLine("=========================================\n");

                    var cmd = new SqlCommand("Insert Employee (FirstName, LastName, Title, BirthDate, HireDate) values (@FirstName, @LastName, @Title, @BirthDate, @HireDate)", connection);
                    cmd.Parameters.AddWithValue("@FirstName", NewEmployee.FirstName);
                    cmd.Parameters.AddWithValue("@LastName", NewEmployee.LastName);
                    cmd.Parameters.AddWithValue("@Title", NewEmployee.Title);
                    cmd.Parameters.AddWithValue("@BirthDate", NewEmployee.BirthDate);
                    cmd.Parameters.AddWithValue("@HireDate", NewEmployee.HireDate);

                    connection.Open();
                    cmd.ExecuteNonQuery();
                    connection.Close();

                    Console.WriteLine("\nFinsihed Creating a new employee:");
                    Console.WriteLine("=========================================\n");
                }
                catch (SqlException e)
                {
                    Console.WriteLine(e.ToString());
                }
            }
        }

        static void QueryItems()
        {
            connection = new SqlConnection(connectionstring);

            using (connection)
            {
                try
                {
                    Console.WriteLine("\nQuerying database:");
                    Console.WriteLine("=========================================\n");

                    var cmd = new SqlCommand("SELECT * FROM Employee WHERE LastName = @LastName", connection);
                    cmd.Parameters.AddWithValue("@LastName", NewEmployee.LastName);

                    connection.Open();
                    cmd.ExecuteNonQuery();

                    using (SqlDataReader reader = cmd.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            for (int i = 0; i < reader.FieldCount; i++)
                            {
                                Console.WriteLine(reader.GetValue(i));
                            }
                        }
                        connection.Close();
                    }
                    Console.WriteLine("\nFinsihed querying database:");
                    Console.WriteLine("=========================================\n");
                }
                catch (SqlException e)
                {
                    Console.WriteLine(e.ToString());
                }
            }
        }

        static void UpdateEmployeeItem()
        {
            connection = new SqlConnection(connectionstring);

            using (connection)
            {
                try
                {
                    Console.WriteLine("\nUpdating employee:");
                    Console.WriteLine("=========================================\n");

                    var cmd = new SqlCommand(" UPDATE Employee SET FirstName = 'Molly' WHERE Employeeid = 1", connection);

                    connection.Open();
                    cmd.ExecuteNonQuery();
                    connection.Close();

                    Console.WriteLine("\nFinished updating employee");
                    Console.WriteLine("=========================================\n");
                }
                catch (SqlException e)
                {
                    Console.WriteLine(e.ToString());
                }
            }
        }
        static void DeleteEmployeeItem()
        {
            connection = new SqlConnection(connectionstring);

            using (connection)
            {
                try
                {
                    Console.WriteLine("\nDeleting employee:");
                    Console.WriteLine("=========================================\n");

                    var cmd = new SqlCommand(" Delete FROM dbo.Employee where Employeeid = 1", connection);

                    connection.Open();
                    cmd.ExecuteNonQuery();
                    connection.Close();

                    Console.WriteLine("\nFinished deleting employee");
                    Console.WriteLine("=========================================\n");
                }
                catch (SqlException e)
                {
                    Console.WriteLine(e.ToString());
                }
            }
        }
    }
}