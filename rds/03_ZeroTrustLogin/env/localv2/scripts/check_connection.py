# This is a Python example - not Terraform code
# Save as connect_rds.py
import boto3
import psycopg2
import ssl

import os

def get_auth_token(hostname, port, username, region):
    """Generate an IAM authentication token."""
    client = boto3.client('rds', region_name=region)
    token = client.generate_db_auth_token(
        DBHostname=hostname,
        Port=port,
        DBUsername=username,
        Region=region
    )
    return token

def main():
    try:
        (hostname, port, username, region, db) = (
            os.environ["DB_HOSTNAME"],
            int(os.environ["DB_PORT"]),
            os.environ["DB_USER"],
            os.environ["AWS_REGION"],
            os.environ["DB_NAME"]
        )

        # Generate the authentication token
        token = get_auth_token(
            hostname=hostname,
            port=port,
            username=username,
            region=region
        )

        # Connect using the token as the password
        conn = psycopg2.connect(
            host=hostname,
            port=port,
            database=db,
            user=username,
            password=token,
            sslmode='require'
        )

            # 2. Create a cursor object
        cursor = conn.cursor()
        
        # 3. Execute a SQL query
        cursor.execute("SELECT version();")
        
        # 4. Fetch the results
        db_version = cursor.fetchone()
        print(f"Connected to PostgreSQL version: {db_version}")
        
    except Exception as e:
        print(f"Connection failed: {e}")
    finally:
        # 5. Clean up and close connections
        if 'cursor' in locals():
            cursor.close()
        if 'connection' in locals():
            connection.close()
            print("PostgreSQL connection is closed.")


if __name__ == "__main__":
    main()