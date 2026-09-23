import pandas as pd


# Load the CSV dataset
df = pd.read_csv("Dataset/Sales_Dataset.csv")


# Display the first five rows
print("FIRST FIVE ROWS")
print(df.head())


# Display the number of rows and columns
print("\nDATASET SHAPE")
print(df.shape)


# Display column names and data types
print("\nDATASET INFORMATION")
df.info()


# Display numerical summary
print("\nNUMERICAL SUMMARY")
print(df.describe())


# =====================================================
# QUESTION 2: HANDLE MISSING VALUES AND DUPLICATES
# =====================================================

print("\nMISSING VALUES BY COLUMN")
print(df.isnull().sum())


# Calculate the total number of missing cells
total_missing = df.isnull().sum().sum()

print("\nTOTAL MISSING VALUES")
print(total_missing)


# Count duplicate rows
duplicate_rows = df.duplicated().sum()

print("\nDUPLICATE ROWS")
print(duplicate_rows)


# Remove duplicate rows if any exist
df_cleaned = df.drop_duplicates().copy()


# Convert order_date from text into a proper date datatype
df_cleaned["order_date"] = pd.to_datetime(
    df_cleaned["order_date"],
    errors="coerce"
)


print("\nROWS BEFORE CLEANING")
print(len(df))

print("\nROWS AFTER CLEANING")
print(len(df_cleaned))

print("\nORDER DATE DATATYPE")
print(df_cleaned["order_date"].dtype)


invalid_dates = df_cleaned["order_date"].isnull().sum()

print("\nINVALID DATES AFTER CONVERSION")
print(invalid_dates)

# The dataset contained no missing values or duplicate rows.
# Therefore, no values were replaced and no records were removed.


# =====================================================
# QUESTION 3: CATEGORY REVENUE ANALYSIS
# =====================================================

category_revenue = (
    df_cleaned
    .groupby("category", as_index=False)
    .agg(
        total_orders=("order_id", "nunique"),
        units_sold=("quantity", "sum"),
        total_revenue=("total_price", "sum")
    )
    .sort_values(
        by="total_revenue",
        ascending=False
    )
)


print("\nCATEGORY REVENUE ANALYSIS")
print(category_revenue)


category_revenue.to_csv(
    "Result/python_category_revenue.csv",
    index=False
)


# =====================================================
# QUESTION 4: SORT DATA BY MULTIPLE COLUMNS
# =====================================================

sorted_sales = (
    df_cleaned
    .sort_values(
        by=["category", "total_price"],
        ascending=[True, False]
    )
    .reset_index(drop=True)
)


print("\nDATA SORTED BY CATEGORY AND TOTAL PRICE")
print(
    sorted_sales[
        [
            "order_id",
            "customer_name",
            "category",
            "product_name",
            "total_price"
        ]
    ].head(20)
)

sorted_sales.to_csv(
    "Result/python_sorted_sales.csv",
    index=False
)


# =====================================================
# QUESTION 5: CORRELATION MATRIX
# =====================================================

numerical_columns = [
    "quantity",
    "unit_price",
    "total_price"
]


correlation_matrix = (
    df_cleaned[numerical_columns]
    .corr()
    .round(3)
)


print("\nCORRELATION MATRIX")
print(correlation_matrix)


correlation_matrix.to_csv(
    "Result/python_correlation_matrix.csv"
)