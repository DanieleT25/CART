import matplotlib.pyplot as plt
import seaborn as sns
from matplotlib.ticker import PercentFormatter
import pandas as pd
import matplotlib.colors as mcolors
import matplotlib.cm as cm


def plot_revenue_trend(df_trend):
    sns.set_theme(style="whitegrid")

    # Create the figure and the first axis (Left Y-axis for Revenue)
    fig, ax1 = plt.subplots(figsize=(12, 6))

    # Plot 1: Total Revenue Line
    color_revenue = '#1f77b4'  # Corporate Blue
    ax1.set_xlabel('Month-Year (Chronological)', fontsize=12, labelpad=10)
    ax1.set_ylabel('Total Revenue (£)', color=color_revenue, fontsize=12, fontweight='bold')
    line1 = ax1.plot(df_trend['month_year'], df_trend['total_revenue'], 
                    color=color_revenue, marker='o', linewidth=2.5, label='Total Revenue (£)')
    ax1.tick_params(axis='y', labelcolor=color_revenue)
    # Format numbers on the Y-axis with a thousands separator
    ax1.yaxis.set_major_formatter(plt.FuncFormatter(lambda x, loc: "{:,}".format(int(x))))

    # Create the second axis (Right Y-axis for Orders) sharing the same X-axis
    ax2 = ax1.twinx()  

    # Plot 2: Total Orders Line
    color_orders = '#2ca02c'  # Operational Green
    ax2.set_ylabel('Total Orders (Unique Baskets)', color=color_orders, fontsize=12, fontweight='bold')
    line2 = ax2.plot(df_trend['month_year'], df_trend['total_orders'], 
                    color=color_orders, marker='s', linestyle='--', linewidth=2, label='Total Orders')
    ax2.tick_params(axis='y', labelcolor=color_orders)
    ax2.yaxis.set_major_formatter(plt.FuncFormatter(lambda x, loc: "{:,}".format(int(x))))

    # Rotate the date labels on the X-axis to prevent overlapping
    ax1.set_xticklabels(df_trend['month_year'], rotation=45, ha='right')

    # Combine the legends from both axes into a single box placed in the upper left
    all_lines = line1 + line2
    all_labels = [l.get_label() for l in all_lines]
    ax1.legend(all_lines, all_labels, loc='upper left', fontsize=11, frameon=True)

    # Descriptive chart title
    plt.title('Monthly Evolution of Revenue and Order Volume (2010-2011)', 
            fontsize=14, fontweight='bold', pad=20)

    # Layout optimization to prevent text clipping
    plt.tight_layout()

    # Display the plot in the notebook
    plt.show()

def plot_geographic_AOV(df_geographic):
    # Set the visual style
    sns.set_theme(style="whitegrid")

    # Filter out the United Kingdom and Unspecified to focus exclusively on international markets
    df_international = df_geographic[(df_geographic['country'] != 'United Kingdom') & 
                                     (df_geographic['country'] != 'Unspecified')].head(10).copy()

    # Create a single plot figure
    plt.figure(figsize=(12, 7))

    # --- Bivariate Color Mapping based on Total Orders ---
    # Normalize the order values between 0 and 1 for the colormap
    norm = mcolors.Normalize(vmin=df_international['total_orders'].min(), 
                             vmax=df_international['total_orders'].max())
    
    # Choose the 'Oranges' colormap (higher values will be darker)
    cmap = cm.get_cmap('Oranges')
    
    # Generate the exact list of colors for each country based on its total orders
    custom_colors = [cmap(norm(val)) for val in df_international['total_orders']]

    # Create the horizontal barplot
    ax = sns.barplot(
        data=df_international,
        x='total_revenue',
        y='country',
        palette=custom_colors,
        hue='country', # Added to avoid warnings in newer versions of Seaborn
        legend=False
    )
    
    # Add the AOV and total orders text next to each bar
    for i, p in enumerate(ax.patches):
        aov_val = df_international.iloc[i]['average_order_value']
        ord_val = df_international.iloc[i]['total_orders']
        
        # Print the extra values to the right of the bar
        ax.annotate(f' AOV: £{aov_val} | Orders: {ord_val}', 
                    (p.get_width(), p.get_y() + p.get_height() / 2.), 
                    va='center', xytext=(5, 0), textcoords='offset points', 
                    fontsize=10, fontweight='500', color='#333333')
        
    # Extend the X-axis limit slightly to make room for the text annotations
    ax.set_xlim(0, ax.get_xlim()[1] * 1.25)

    # Titles and labels
    plt.title('Top 10 International Markets: Revenue vs Order Volume', 
              fontsize=14, fontweight='bold', pad=15)
    plt.xlabel('Total Revenue (£) - (Bar Length)', fontsize=11, fontweight='bold')
    plt.ylabel('Country', fontsize=11, fontweight='bold')
    
    # Format numbers on the X-axis with a thousands separator
    plt.gca().xaxis.set_major_formatter(plt.FuncFormatter(lambda x, loc: "{:,}".format(int(x))))

    # Add a footnote to explain the bivariate visual encoding
    plt.figtext(0.15, 0.01, 
                "Visual Note: Bar length indicates Total Revenue. Color intensity represents the volume of Total Orders.", 
                fontsize=9, style='italic', color='gray')

    # Layout optimization
    plt.tight_layout()
    plt.show()

def plot_heatmap_orari(df_orari):
    # 1. FIX DATA TYPE: Force the orders column to be a pure integer
    df_orari['total_orders'] = pd.to_numeric(df_orari['total_orders'], errors='coerce').fillna(0).astype(int)

    # 2. Data Optimization: Order the days of the week
    order_days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday']
    df_orari['day_of_week'] = pd.Categorical(df_orari['day_of_week'], categories=order_days, ordered=True)

    # 3. Create the Pivot Matrix
    # FIX WARNING: Add observed=False to retain empty categories (like Saturday)
    pivot_orari = df_orari.pivot_table(
        index='time_of_day', 
        columns='day_of_week', 
        values='total_orders', 
        aggfunc='sum', 
        fill_value=0,
        observed=False 
    )

    # Ensure the entire matrix is formatted as integers
    pivot_orari = pivot_orari.astype(int)
    pivot_orari = pivot_orari.sort_index()

    # 4. Heatmap Configuration and Plotting
    plt.figure(figsize=(14, 7))
    sns.set_theme(style="white") 

    heatmap = sns.heatmap(
        pivot_orari, 
        annot=True,          
        fmt='d',             
        cmap='YlGnBu',       
        linewidths=.5,       
        cbar_kws={'label': 'Order Volume (Baskets)'} 
    )

    plt.title("Heatmap: Order Concentration (Days vs. Time Brackets)", 
            fontsize=15, fontweight='bold', pad=20)
    plt.xlabel("Day of the Week", fontsize=12, labelpad=10)
    plt.ylabel("Macro Time Bracket", fontsize=12, labelpad=10)

    plt.xticks(rotation=45)
    plt.yticks(rotation=0)

    plt.tight_layout()
    plt.show()

def rfm_scatter(df_rfm_sample):
    # 1. FIX DATA TYPES
    df_rfm_sample['Recency'] = pd.to_numeric(df_rfm_sample['Recency'], errors='coerce').fillna(0).astype(int)
    df_rfm_sample['Frequency'] = pd.to_numeric(df_rfm_sample['Frequency'], errors='coerce').fillna(0).astype(int)
    df_rfm_sample['Monetary'] = pd.to_numeric(df_rfm_sample['Monetary'], errors='coerce').fillna(0).astype(float)

    # 2. Configure visual style
    plt.figure(figsize=(12, 8))
    sns.set_theme(style="whitegrid")

    norm = mcolors.LogNorm(vmin=df_rfm_sample['Monetary'].min() + 1, vmax=df_rfm_sample['Monetary'].max())

    # 3. Create the Bubble Scatter Plot on the sample
    scatter = plt.scatter(
        x=df_rfm_sample['Recency'],
        y=df_rfm_sample['Frequency'],
        s=df_rfm_sample['Frequency'] * 5,  
        c=df_rfm_sample['Monetary'],         
        cmap='viridis',
        norm=norm,
        alpha=0.6,                  
        edgecolors='w',
        linewidth=0.5
    )

    # Note: Because we are sampling randomly, our specific "Whales" (e.g., ID 14646) might not be in the plot. 
    # We avoid hardcoded annotations and let the chart show the clean overall distribution.

    # 4. Axis and title optimization
    plt.title("RFM Spatial Analysis: Distribution (20% Random Sample - Log Scale)", fontsize=15, fontweight='bold', pad=20)
    plt.xlabel("Recency (Days since last purchase - Lower is better)", fontsize=12)
    plt.ylabel("Frequency (Number of unique orders - Higher is better)", fontsize=12)

    cbar = plt.colorbar(scatter, pad=0.02)
    cbar.set_label('Cumulative Total Spend (£) - Log Scale', fontsize=11, weight='bold')
    cbar.ax.yaxis.set_major_formatter(plt.FuncFormatter(lambda x, loc: "{:,}".format(int(x))))

    plt.tight_layout()
    plt.show()

def plot_cohort_heatmap(df_cohort):
    # 1. Create the Pivot Matrix
    # Rows = Acquisition Month (Cohort), Columns = Subsequent month index (0, 1, 2...)
    cohort_pivot = df_cohort.pivot_table(
        index='acquisition_month', 
        columns='retention_month_index', 
        values='active_customers'
    )

    # 2. Calculate Percentage Retention Rates
    # 'Month 0' represents 100% of the cohort. We divide all subsequent months by Month 0.
    cohort_size = cohort_pivot.iloc[:, 0]
    retention_matrix = cohort_pivot.divide(cohort_size, axis=0)

    # ---> THE FIX: Force the conversion of Pandas NAType to classic Numpy NaN <---
    retention_matrix = retention_matrix.astype('float64')

    # 3. Chart Configuration
    plt.figure(figsize=(16, 10))
    sns.set_theme(style="white")

    # We choose a palette that ranges from white (0%) to dark green (100%)
    # We use fmt='.0%' to format decimals directly into percentages (e.g., 0.25 -> 25%)
    sns.heatmap(
        retention_matrix, 
        annot=True, 
        fmt='.0%', 
        cmap='Greens', 
        vmin=0.0,
        vmax=0.5, # Cap the maximum at 50% to provide visual contrast
        linewidths=.5,
        cbar_kws={'label': 'Retention Rate (%)'}
    )

    # 4. Visual Optimization
    plt.title("Customer Retention Matrix (Cohort Analysis)", fontsize=16, fontweight='bold', pad=20)
    plt.xlabel("Months Elapsed Since First Purchase (Month 0 = Acquisition)", fontsize=12, labelpad=10)
    plt.ylabel("Cohort (Month of First Purchase)", fontsize=12, labelpad=10)

    plt.yticks(rotation=0)

    plt.tight_layout()
    plt.show()

def plot_pareto(df_pareto):
    # 1. Figure configuration (extra wide to accommodate 50 labels)
    fig, ax1 = plt.subplots(figsize=(20, 9))
    sns.set_theme(style="white")

    # Professional colors
    color_bar = '#3498db'  # Light blue for the bars (Single revenue)
    color_line = '#e74c3c' # Red for the line (Cumulative)

    # 2. Create the Bar Chart (Absolute Revenue)
    ax1.bar(df_pareto['product_name'], df_pareto['total_revenue'], color=color_bar, alpha=0.8)
    ax1.set_ylabel('Single Product Revenue (£)', color=color_bar, fontsize=12, fontweight='bold', labelpad=10)
    ax1.tick_params(axis='y', labelcolor=color_bar)
    ax1.yaxis.set_major_formatter(plt.FuncFormatter(lambda x, loc: "{:,}".format(int(x))))

    # Rotate the X-axis labels by 90 degrees so they all fit
    ax1.set_xticklabels(df_pareto['product_name'], rotation=90, fontsize=9)

    # 3. Create the Line Chart (Cumulative Percentage) on the second Y-axis
    ax2 = ax1.twinx()
    ax2.plot(df_pareto['product_name'], df_pareto['cumulative_percentage'], color=color_line, marker='D', ms=5, linewidth=2.5)

    # Format the right axis as percentages
    ax2.yaxis.set_major_formatter(PercentFormatter())
    ax2.set_ylabel('Cumulative Percentage of Company Total (%)', color=color_line, fontsize=12, fontweight='bold', labelpad=10)
    ax2.tick_params(axis='y', labelcolor=color_line)

    # Fix the maximum limit of the secondary Y-axis based on the data (e.g., 25% since we reach 21.4%)
    ax2.set_ylim(0, df_pareto['cumulative_percentage'].max() + 2)

    # 4. Visual Optimization
    plt.title("Pareto Chart: Top 50 Products (1.4% of Catalog Generates 21.4% of Revenue)", 
            fontsize=16, fontweight='bold', pad=20)

    plt.tight_layout()
    plt.show()