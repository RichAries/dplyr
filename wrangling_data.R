#update loaded package
install.packages("withr")

install.packages("dplyr")
library(dplyr)
library(readr)
library(tidyr)
departments<-read_delim("employee/departments.csv",delim=";")
titles<-read_delim("employee/titles.csv",delim=";")
salaries<-read_delim("employee/salaries.csv",delim=";")
employees<-read_delim("employee/employees.csv",delim=";")
dept_manager<-read_delim("employee/dept_manager.csv",delim=";")
dept_emp<-read_delim("employee/dept_emp.csv",delim=";")

######################################Trimming Operations######################################
###############################################################################################

##########################################Select (SELECT)
#Select by column name:
select(employees,birth_date,first_name)

#Select by column range:
select(employees,emp_no:last_name)

#Select by name search, for example, all columns that end with "_name":
select(employees,ends_with("_name"))

#Rearrange how columns appear by order:
select(employees,first_name,birth_date)

#Select columns by exclusion (select all columns, EXCEPT first_name):
select(employees,-first_name)

#Similar to the * in SQL
select(employees, everything())

##########################################Sort -- Arrange (ORDER BY)
#Sort by one column:
arrange(employees,first_name)
#Sort by one column descending:
arrange(employees,desc(first_name))

#Sort by many columns:
arrange(employees,first_name,gender)

#Some sorting which may include multiple descending orders:
arrange(employees,desc(hire_date),desc(last_name),first_name,gender)


##########################################Filtering (WHERE)
#Filter by a single condition:
filter(employees,gender=="F")
filter(employees,first_name=="Mary")

#Filter by more than one condition, where BOTH need to be true(AND):
filter(employees,gender=="F"&first_name=="Mary")

#Alternatively, you can filter by condition, where at least one condition 
#should be true, but not necessarily all of them(OR):
filter(employees,first_name=="Leah"|first_name == "Mary")
filter(employees,(first_name=="Leah"|first_name == "Mary")&gender=="F")

#Of course, we can also filter by using a vector:
filter(employees,first_name %in% c("Leah","Mary"))

#Suppose we selected one column and stored the resulting table:
temp_table<-select(employees,gender)

#Now, we can filter this data by returning back only distinct rows.
#This is, we can remove duplicate rows, if they exist, using:
distinct(temp_table)

#We can also filter data by selecting a random sample of rows:
set.seed(12)#Set.seed can return the same result when running the following command
sample_n(employees,5)

#Or, we can randomly select a percentage of rows (hint, 
#this is quite useful for machine learning models that
#need train/test splits).  For example, this will sample
#0.005% of the data:
sample_frac(employees,0.00005)

#We also can filter by slicing.  We can specify a 
#range of rows to select:
employees
slice(employees,3:5)

#Last, we can filter by first sorting and then
#looking the "top n" number of observations in the
#sorted list.  For example, we can find the top 5
#salaries throughout the firm:
top_n(salaries,5,salary)

temp<-arrange(salaries,desc(salary))
slice(temp,1:5)

slice_max(salaries,salary,n=5)
##########################################Renaming (AS)
#We can rename a table's column by using the new name, and "=" sign, 
#followed by the older name of the column, like this:
rename(employees,gen = gender)

#We also can do this for multiple columns:
rename(employees,gen = gender, FN = first_name)

#If we were really dedicated, and really wanted a space in our
#column names (which is VERY bad practice), we can do this by using
#quotations:
rename(employees,"First Name" = first_name)


#However, column names with spaces must ALWAYS use quotations
#around them to refer to them.

######################################Multiple Operations######################################
###############################################################################################
#We can use more than one operation on the same table to obtain the table we want.
#Doing so would mean applying one operation to the table, taking the output, and 
#subsequently applying the next operation to this output.  We continue in this 
#fashion with multiple operations to obtain the data we seek. 

#For example, suppose we wanted to select the first name, last name, and gender,
#rename these columns to FN, LN, GEN, return only the employees whose first name 
#is "Mary", and then sort the data by gender.  We can do this by applying a 
#sequence of operations, one at a time, taking the output, storing it in a variable,
#passing the variable as input to the next operation, storing this in a variable, etc.
#So, let's see the process of applying these operations, one a time, to obtain the data
#we seek:

temp_data<-select(employees,first_name,last_name,gender)
temp_data<-rename(temp_data,FN = first_name, LN = last_name, GEN = gender)
temp_data<-filter(temp_data,FN=="Mary")
temp_data<-arrange(temp_data,GEN)
temp_data

##########################################Piping
#As we can see, combining multiple operations on the same data table is frustrating,
#since we need to keep storing the output table into a variable, and subsequently
#passing that variable as input into the next operation function.  There is a much
#faster way to accomplish this, and it is by using the piping operator.  The
#piping operator takes the output from the previous operation and automatically inserts
#it as input into the next operation.  To do this, we use the following notation:

# data %>%
#    operation()%>%
#    operation()%>%
#       ...
#    operation()

#This is the same thing as:

#temp <- operation(data)
#temp <- operation(temp)
#     ....
#temp <- operation(temp)

#So, using the previous operations, we could have typed instead
temp_data <- employees%>%
  select(first_name,last_name,gender)%>%
  rename(FN = first_name, LN = last_name, GEN = gender)%>%
  filter(FN == "Mary")%>%
  arrange(GEN)
temp_data


###################################Transformation Operations###################################
###############################################################################################

##########################################Aggregation 
#These take vectors and convert them into single values.
#We can count unique categories in a given column:
employees%>%
  count(gender)

#Or we can summarize numerically (aka, aggregate), the entire table by providing 
#the "summarize" function a summary function:
salaries%>%
  summarize(avg = mean(salary),sd = sd(salary),max=max(salary))

#If we had multiple numerical columns, we can apply summary
#functions to more than one column by using the "across" function:
salaries%>%
  select(emp_no,salary)%>%
  summarize(across(everything(),c(mean,sd,min,max)))

#Count number of rows:
employees%>%
  summarize(s_count = n())

#This makes more sense if we first convert to a new unit 
#of analysis, and subsequently count how many unique
#observations of this new unit exist.  We can convert the unit
#of analysis by using the "group_by" function.  After specifying
#the new unit, we can then perform aggregation functions.  For 
#example, let's convert the unit of analysis to gender.  So, 
#there should be two reported observations, and the way we are 
#"putting the observations together" is by way of counting how
#many (by way of the "n" function) observations fall within each
#group:
employees%>%
  group_by(gender)%>%
  summarize(s_count = n())

employees%>%
  filter(gender=="F" & hire_date== "1985-02-01")

#Other ways to (1) change the unit of analysis and (2) aggregate:
#Numerical quantities (Employee-Date Range --> Date Range):
salaries%>%
  group_by(from_date,to_date)%>%
  summarize(avg_salary_range = mean(salary), 
            sd_salary_range = sd(salary),
            n_count = n())

#Employee-Date Range --> Employee
salaries%>%
  group_by(emp_no)%>%
  summarize(num_of_salaries = n(),
            first_salary = first(salary),
            last_salary = last(salary),
            iqr = IQR(salary))%>%
  arrange(emp_no)


##########################################Mutation/ Value Replacement 
#Mutation helps us create new columns using existing
#ones, but it also helps us do value replacement.
#We create new columns by using vectorized functions,
#which are functions that take columns as input, and
#provide columns as output:

#Basic Math
#We can add a single value to every row to create a new column:
salaries%>%
  mutate(appended_value = 1)

#Or, we can perform an operation on a column, and repeat it:
salaries%>%
  mutate(mean_salary = mean(salary))

#We can perform operations like subtraction:
salaries%>%
  mutate(mean_salary = mean(salary))%>%
  mutate(salary_from_mean = salary - mean_salary)

#We can also discretize by creating equal-sized bins:
salaries %>%
  mutate(salary_category = ntile(salary,5))

#Or, of course, perform more complex operations, like
#convert the salary to percentage of average salary:
salaries%>%
  mutate(percent_of_average = paste0(round(100*salary/mean(salary),2),"%"))

#We can also do value replacement, such as replacing NAs:
salaries%>%
  sample_n(100)%>%
  group_by(emp_no)%>%
  summarize(sd_salary = sd(salary))%>%
  mutate(salary_fixed = coalesce(sd_salary,0))

#or, using if statements to create new columns::
salaries%>%
  mutate(mean_salary = mean(salary))%>%
  mutate(salary_from_mean = salary - mean_salary)%>%
  mutate(above_below = if_else(salary_from_mean<0,
                               "Less than Average",
                               "More than Average"))

##########################################Reshaping
#Reshaping operations take the data in one format and trasform it into another.
#While these are not technically the same as aggregating, they are still changing
#the unit of analysis, and so, these are indeed tranformation operations.
#Let us start by looking at how we can convert from wide format to long:
employees_long<-employees%>%
  gather("property", "value",birth_date:hire_date)%>%
  arrange(emp_no)

#Let's take a look:
View(employees_long)

#Notice the date messed up.  We can correct this by using string:
employees$birth_date<-as.character(employees$birth_date)
employees$hire_date<-as.character(employees$hire_date)

#Try again:
employees_long<-employees%>%
  gather("property", "value",birth_date:hire_date)%>%
  arrange(emp_no)

#Let's take a look:
View(employees_long)

#We can go back to wide format from long format.:
employees_long %>%
  spread("property","value")

#We can also join columns together:
named<-employees%>%
  unite("name",c("first_name","last_name"), sep=" ")

#Or, we can split one column to many based on a delimiter:
named%>%
  separate(name,c("firstName","lastName"),sep=" ")

#A word of caution, we must ALWAYS ensure we do NOT include a column
#that is used to define our unit of analysis.  For example, suppose we
#did this:
salaries$from_date<-as.character(salaries$from_date)
salaries$to_date<-as.character(salaries$to_date)

salaries_long<-salaries%>%
  gather("column","value",salary:to_date)%>%
  arrange(emp_no)

View(salaries_long)

# Everything appears okay, but let's try to reverse this process:
salaries_wide<-salaries_long%>%
  spread("column","value")

#Oh no!  So what is happening here.  Let us look at rows 18 and 19:
salaries_long[c(18,19),]

#Notice how we have two values for the property of "from_date" for 
#the employee 10001.  This is a problem.  When R goes to construct
#the table with the unit of anlaysis being the emp_no - date range, 
#it cannot pair the from date to the to date.  The reason is due
#to the fact that we threw in a column that is used for unique 
#identification into our original gathering process.  When we do this
#we loose the ability to uniquely define employees in time ranges.
#So, rule of thumb: never, ever, EVER put a unique ID into the gather,
#unless, of course, you are willing to do aggregation, BUT, that is
#a different operation.  By the way, we could have done this.  First
#combine all columns that uniquly define the unit of analysis:
sal_temp<-salaries%>%
  unite("employee_date_id",c("emp_no","from_date","to_date"),sep="_")

salaries_long<-sal_temp%>%
  gather("column","value",salary)%>%
  arrange(employee_date_id)

View(salaries_long)

#Now we should be able to reverse the process with no issue:
sal_temp<-salaries_long%>%
  spread("column","value")

#Split the ID:
sal_temp%>%
  separate(employee_date_id,c("emp_no","from_date","to_date"),sep="_")

#######################################Combining Operations####################################
###############################################################################################

##########################################Inner Join
#As we discussed, inner joins allow us to join two or more tables based on some common column of
#values.  If both tables have the same values, then the rows are kept.  However, if either table
#is missing a value in the "join column(s)", then the row in either table is thrown away.  For
#example, suppose we had the following data in one table:
student<-c("Bob","Bob","Kelly","Susan")
tool_id<-c(1,2,2,1)
student_tool_data<-tibble(student,tool_id)

#And the following table, which describes a tool and the course it's used in:
tool_id<-c(1,1)
tool_name<-c("R","R")
course<-c("Visualization","Marketing Analytics")
tool_course_data<-tibble(tool_id,tool_name,course)

#Our goal is to take the left table (student_tool_data), and put new columns in it,
#where the new columns will be "tool_name" and "course".  We can join the two tables
#together by using the inner join operation  This works by specifying two tables and
#one or more column names that should be used to match the table rows.  In this example,
#if we use the tool_id as the joining column, then the resulting table will have a unit of 
#anlaysis that will be a combination of the units in each respective table.  In this case,
#the unit of the left table is Student-Tool, while the unit in the other table is Tool - Course.
#Hence, combining these tables will create a new unit, which will be Student-Tool-Course:
student_tool_data%>%
  inner_join(tool_course_data,"tool_id")

#We can also join multiple tables together.  For example, we could join the salaries with
#the employees table.  We subsequently can join to that table the dept_emp table, and after
#that the employees table:

#Ensure dates are in character format for now:
dept_emp$from_date<-as.character(dept_emp$from_date)
dept_emp$to_date<-as.character(dept_emp$to_date)

#Do the joins:
salaries%>%
  inner_join(employees)%>%
  inner_join(dept_emp,by=c("emp_no"))%>%
  inner_join(departments)%>% 
  View()
#Now, you can see this might be a problem.  The salary table:
salaries%>%
  arrange(emp_no)%>%
  group_by(emp_no)%>%
  count()%>%
  filter(n>1)

#has multiple employee ids, but this is different than the dept_emp table
#which has multiple employee ids as well, but a different number of them:
dept_emp%>%
  arrange(emp_no)%>%
  group_by(emp_no)%>%
  count()%>%
  filter(n>1)

#This is a problem.  Why?  Well, let's look at one of the employee ids with more than
#one entry in dept_emp:

salaries%>%
  filter(emp_no == 10010)

dept_emp%>%
  filter(emp_no == 10010)

#This means, there's going to be 12 rows in the joined table:
salaries%>%
  inner_join(employees)%>%
  inner_join(dept_emp,by=c("emp_no"))%>%
  inner_join(departments)%>%
  filter(emp_no==10010)%>%
  View()

#However, this is strange, because the dates will NOT match.  In reality, we should
#join the salaries table with the dept_emp table by using emp_no, from_date, to_date
#as the join columns to avoid this issue:
salaries%>%
  inner_join(employees)%>%
  inner_join(dept_emp,by=c("emp_no","from_date","to_date"))%>%
  inner_join(departments)%>%
  View()

##########################################Appending
#Let us suppose we randomly sample a few rows from our departments data:
set.seed(5)
sample_1<-departments%>%
  sample_n(4)

#Now let's do it again:
set.seed(50)
sample_2<-departments%>%
  sample_n(3)

#If we wanted to put these two tables together, we can.  They both have the 
#same columns, and the same units of analysis.  We can easily put them together:
sample_1%>%
  bind_rows(sample_2)%>%
  arrange(dept_name)

#As you can see, there are duplicates.

#You also can put two tables with the same number of rows together column-wise
#so long as each row in each table represents the same thing:

#Randomly sample rows
set.seed(5)
sample_table<-employees%>%
  sample_n(4)

#Split the tables by column:
table_1<- sample_table%>%
  select(emp_no:last_name)
table_2<- sample_table%>%
  select(gender:hire_date)

#Now we have two different tables.  We can join them column wise since the 
#number of rows in each table (1) are the same and (2) represent the same thing:
table_1%>%
  bind_cols(table_2)

##########################################Join-Filtering
#Recall that table joins can be used to filter through data.  These operations do 
#no inherently change the structure of the data, but rather, use data from a different
#table to either (1) select rows that have values which exist in a column in the other table
#or (2) avoid values that are in the other table.  For example, suppose we have the following table:

emp_sals<-salaries%>%
  inner_join(employees)%>%
  inner_join(dept_emp,by=c("emp_no","from_date","to_date"))%>%
  inner_join(departments)%>%
  select(first_name,last_name,salary,gender, dept_name,from_date,to_date)

#########################Semi-Joins
#Suppose we only want to get employees who are in this table (which, not all of them
#will be if we did not have matching department and employee data).  We can 
#do this using a semi-join:
emps<-employees%>%
  semi_join(emp_sals)

#What happened here?  Well, R went to go look for an employee using first_name,
#last_name, and gender where the exact combination of those three exists in the 
#emp_sals table.  If the combo is not in the emp_sals table, it ignores it.

#Now suppose we randomly sample a few employees from this table:
set.seed(5)
employee_samps<-emps%>%
  sample_n(10)
employee_samps

#Suppose we wanted all the information from our first table (emp_sals) about these
#specific employees that were just sampled.  We can do that again with a semi-join:
reduced_emp_sals<-emp_sals%>%
  semi_join(employee_samps)
reduced_emp_sals

#Now suppose we select from the departments table:
set.seed(1)
samp_deps<-departments%>%
  sample_n(3)

#########################Anti-Joins:
#Now, suppose we would like to remove information from
#the reduced_emp_sals column whose departments are in the 
#samp_deps.  We can do this using what is called an anti-join.  An anti-join
#will use the join column to determine if it should leave rows out of the data.
#Again, it does not change the data, but it merely filters data out of the table 
#based on values that are matched in the corresponding table:
reduced_emp_sals%>%
  anti_join(samp_deps)

##########################################Set Appending
#Earlier we saw how we can append data row and column wise.  However, there are 
#special row-based operations we can perform on the tables that allow us to 
#undertake actions such as removing duplicates as well as preserving or removing 
#entire rows based on other rows.

#########################Unions
#Recall we can sample:
set.seed(5)
sample_1<-departments%>%
  sample_n(4)

set.seed(50)
sample_2<-departments%>%
  sample_n(3)

#Earlier, we put these two table together by appending.  However
#doing so keeps duplicates:
sample_1%>%
  bind_rows(sample_2)

#A different way to do this is by unioning, which will append the rows,
#but only keep unique occurrances:
sample_1%>%
  union(sample_2)

#########################Set Difference
#We also can keep the entire table, but remove entire rows that occur in the 
#other table.  Note that this is not the same as an anti-join.  Anti-joins
#remove rows based on the values in join-columns, while set-differences remove
#rows only if an entire row exists in both tables:
sample_1%>%
  setdiff(sample_2)
sample_2%>%
  setdiff(sample_1)

#########################Intersection
#We also can find all of the rows that exist in both tables:
sample_1%>%
  intersect(sample_2)


