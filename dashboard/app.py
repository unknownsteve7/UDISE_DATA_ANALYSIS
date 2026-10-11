import os
# pyrefly: ignore [missing-import]
import streamlit as st
import pandas as pd
# pyrefly: ignore [missing-import]
import numpy as np
# pyrefly: ignore [missing-import]
import plotly.express as px
# pyrefly: ignore [missing-import]
import plotly.graph_objects as go

# -----------------------------------------------------------------------------
# Page Configuration & Styling
# -----------------------------------------------------------------------------
st.set_page_config(
    page_title="UDISE+ National Policy & Analytics Dashboard",
    page_icon="🎓",
    layout="wide",
    initial_sidebar_state="expanded",
)

st.markdown("""
<style>
    /* Metric Card Styling */
    div[data-testid="stMetricValue"] {
        font-size: 1.8rem;
        font-weight: 700;
        color: #1E3A8A;
    }
    div[data-testid="stMetricDelta"] {
        font-size: 0.9rem;
    }
    .kpi-container {
        background: #F8FAFC;
        border-radius: 10px;
        padding: 1rem;
        border: 1px solid #E2E8F0;
        margin-bottom: 1rem;
    }
    .badge-critical {
        background-color: #FEE2E2;
        color: #991B1B;
        padding: 4px 8px;
        border-radius: 6px;
        font-size: 0.8rem;
        font-weight: 600;
    }
    .badge-good {
        background-color: #DCFCE7;
        color: #166534;
        padding: 4px 8px;
        border-radius: 6px;
        font-size: 0.8rem;
        font-weight: 600;
    }
</style>
""", unsafe_allow_html=True)

# -----------------------------------------------------------------------------
# Data Loading & Caching
# -----------------------------------------------------------------------------
DATA_DIR = os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))), "data", "powerbi_exports")

@st.cache_data
def load_data():
    dist_path = os.path.join(DATA_DIR, "district_policy_indicators.csv")
    cohort_path = os.path.join(DATA_DIR, "cohort_transitions_state_district.csv")
    nfhs_path = os.path.join(DATA_DIR, "nfhs5_state_anemia_rates.csv")

    df_dist = pd.read_csv(dist_path)
    df_cohort = pd.read_csv(cohort_path)
    df_nfhs = pd.read_csv(nfhs_path) if os.path.exists(nfhs_path) else pd.DataFrame()

    # Clean strings
    df_dist['state'] = df_dist['state'].astype(str).str.strip().str.upper()
    df_dist['district'] = df_dist['district'].astype(str).str.strip().str.upper()
    df_cohort['state'] = df_cohort['state'].astype(str).str.strip().str.upper()
    df_cohort['district'] = df_cohort['district'].astype(str).str.strip().str.upper()
    if not df_nfhs.empty:
        df_nfhs['state'] = df_nfhs['state'].astype(str).str.strip().str.upper()

    return df_dist, df_cohort, df_nfhs

try:
    df_dist, df_cohort, df_nfhs = load_data()
except Exception as e:
    st.error(f"Error loading export datasets: {e}")
    st.stop()

# -----------------------------------------------------------------------------
# Sidebar Filters
# -----------------------------------------------------------------------------
st.sidebar.image("https://img.icons8.com/fluency/96/education.png", width=64)
st.sidebar.title("UDISE+ Analytics Engine")
st.sidebar.caption("Evidence-Based Educational Policy & Intervention System")
st.sidebar.markdown("---")

all_states = sorted(df_dist['state'].dropna().unique())
selected_states = st.sidebar.multiselect(
    "Select States / UTs (Default: All)",
    options=all_states,
    default=[]
)

filter_state = selected_states if selected_states else all_states

urban_rural_options = ["All", "Rural", "Urban"]
selected_locality = st.sidebar.selectbox("Locality Filter", urban_rural_options, index=0)

# Apply Filters
filtered_dist = df_dist[df_dist['state'].isin(filter_state)]
filtered_cohort = df_cohort[df_cohort['state'].isin(filter_state)]

if selected_locality != "All":
    filtered_dist = filtered_dist[filtered_dist['rural_urban_label'] == selected_locality]
    filtered_cohort = filtered_cohort[filtered_cohort['rural_urban_label'] == selected_locality]

st.sidebar.markdown("---")
st.sidebar.info(
    "📊 **Dataset Coverage**\n\n"
    f"- **States / UTs:** {len(all_states)}\n"
    f"- **Districts Monitored:** {filtered_dist['district'].nunique():,}\n"
    f"- **Academic Years:** 2023–24 vs 2024–25"
)

# -----------------------------------------------------------------------------
# Header & Navigation
# -----------------------------------------------------------------------------
st.title("🎓 National UDISE+ Policy & Educational Insights")
st.markdown(
    "Synthesized analytics over **1.47M schools** across India. "
    "Designed for **District Magistrates, Educational Administrators, and Policy Planners** "
    "to diagnose equity bottlenecks, infrastructure deficits, and retention disparities."
)

tab1, tab2, tab3, tab4, tab5 = st.tabs([
    "📈 Executive Overview & YoY Growth",
    "⚖️ Gender Equity & Retention Funnel",
    "🏫 Infrastructure & RTE Compliance",
    "🎯 District Intervention Matrix",
    "⚙️ Pipeline Architecture & dbt Models"
])

# -----------------------------------------------------------------------------
# TAB 1: Executive Overview & YoY Growth
# -----------------------------------------------------------------------------
with tab1:
    st.subheader("National & State Key Performance Indicators")
    
    col1, col2, col3, col4, col5 = st.columns(5)
    
    total_schools_23 = int(filtered_dist['school_count'].sum())
    total_schools_24 = int(filtered_dist['school_count_24'].sum())
    school_delta = total_schools_24 - total_schools_23
    
    total_enr_23 = int(filtered_dist['total_enr_23'].sum())
    total_enr_24 = int(filtered_dist['total_enr_24'].sum())
    enr_pct_growth = ((total_enr_24 - total_enr_23) / total_enr_23 * 100) if total_enr_23 > 0 else 0
    
    total_girls_24 = int(filtered_dist['total_girls_24'].sum())
    total_boys_24 = int(filtered_dist['total_boys_24'].sum())
    overall_gpi_24 = round(total_girls_24 / total_boys_24, 3) if total_boys_24 > 0 else 0
    
    avg_infra = round(filtered_dist['avg_infra_score_23'].mean(), 2)
    
    total_teachers = int(filtered_dist['total_tch_23'].sum())
    overall_ptr = round(total_enr_23 / total_teachers, 1) if total_teachers > 0 else 0

    col1.metric("Schools (2024-25)", f"{total_schools_24:,}", delta=f"{school_delta:+,} YoY")
    col2.metric("Total Enrollment", f"{total_enr_24/1e6:.2f}M", delta=f"{enr_pct_growth:+.2f}% YoY")
    col3.metric("Gender Parity (GPI)", f"{overall_gpi_24}:1", delta="Parity Baseline 1.00")
    col4.metric("Avg Infra Score (0-7)", f"{avg_infra}/7", delta="7 Core Amenities")
    col5.metric("Pupil-Teacher Ratio (PTR)", f"{overall_ptr}:1", delta="RTE Standard ≤30")

    st.markdown("---")
    
    col_left, col_right = st.columns([3, 2])
    
    with col_left:
        st.markdown("##### 🏛️ State-Wise Enrollment Growth (2023–24 vs 2024–25)")
        state_agg = filtered_dist.groupby('state').agg(
            enr_23=('total_enr_23', 'sum'),
            enr_24=('total_enr_24', 'sum'),
            schools=('school_count_24', 'sum'),
            avg_infra=('avg_infra_score_23', 'mean')
        ).reset_index()
        state_agg['growth_pct'] = ((state_agg['enr_24'] - state_agg['enr_23']) / state_agg['enr_23'] * 100).round(2)
        state_agg = state_agg.sort_values(by='growth_pct', ascending=False)
        
        fig_growth = px.bar(
            state_agg.head(15),
            x='growth_pct',
            y='state',
            orientation='h',
            color='growth_pct',
            color_continuous_scale=['#EF4444', '#F59E0B', '#10B981'],
            labels={'growth_pct': 'YoY Enrollment Growth (%)', 'state': 'State'},
            title="Top States by Enrollment Growth Rate (%)"
        )
        fig_growth.update_layout(yaxis={'categoryorder': 'total ascending'}, height=450, margin=dict(l=0, r=0, t=30, b=0))
        st.plotly_chart(fig_growth, use_container_width=True)

    with col_right:
        st.markdown("##### 📊 Locality & Gender Distribution")
        loc_gender = filtered_dist.groupby('rural_urban_label').agg(
            Boys=('total_boys_24', 'sum'),
            Girls=('total_girls_24', 'sum')
        ).reset_index()
        loc_melted = loc_gender.melt(id_vars='rural_urban_label', value_vars=['Boys', 'Girls'], var_name='Gender', value_name='Students')
        
        fig_loc = px.pie(
            loc_melted,
            values='Students',
            names='rural_urban_label',
            hole=0.45,
            color='rural_urban_label',
            color_discrete_map={'Rural': '#3B82F6', 'Urban': '#8B5CF6'},
            title="Rural vs Urban Student Share"
        )
        fig_loc.update_layout(height=450, margin=dict(l=0, r=0, t=30, b=0))
        st.plotly_chart(fig_loc, use_container_width=True)

# -----------------------------------------------------------------------------
# TAB 2: Gender Equity & Retention Funnel
# -----------------------------------------------------------------------------
with tab2:
    st.subheader("Gender Parity & Secondary Transition Bottlenecks")
    st.markdown(
        "Analysis of crucial drop-off junctions: **Upper Primary to Secondary (Class 8 → 9)** and "
        "**Secondary to Higher Secondary (Class 10 → 11)** broken down by social categories and gender."
    )
    
    col_t1, col_t2 = st.columns(2)
    
    with col_t1:
        st.markdown("##### 🔻 Transition Rates: Class 8 → Class 9")
        cohort_cat = filtered_cohort.groupby('social_category').agg(
            c8_boys=('enr_c8_boys_23', 'sum'),
            c8_girls=('enr_c8_girls_23', 'sum'),
            c9_boys=('enr_c9_boys_24', 'sum'),
            c9_girls=('enr_c9_girls_24', 'sum')
        ).reset_index()
        
        cohort_cat['boys_t_rate'] = (cohort_cat['c9_boys'] / cohort_cat['c8_boys'] * 100).clip(upper=100).round(1)
        cohort_cat['girls_t_rate'] = (cohort_cat['c9_girls'] / cohort_cat['c8_girls'] * 100).clip(upper=100).round(1)
        
        t_rate_df = pd.melt(cohort_cat, id_vars=['social_category'], value_vars=['boys_t_rate', 'girls_t_rate'],
                            var_name='Cohort', value_name='Transition_Rate')
        t_rate_df['Cohort'] = t_rate_df['Cohort'].replace({'boys_t_rate': 'Boys (8→9)', 'girls_t_rate': 'Girls (8→9)'})
        
        fig_t1 = px.bar(
            t_rate_df,
            x='social_category',
            y='Transition_Rate',
            color='Cohort',
            barmode='group',
            color_discrete_map={'Boys (8→9)': '#3B82F6', 'Girls (8→9)': '#EC4899'},
            labels={'social_category': 'Social Category', 'Transition_Rate': 'Transition Rate (%)'},
            title="Class 8 → 9 Transition Rate by Social Category"
        )
        fig_t1.update_layout(height=380, yaxis_range=[50, 105], margin=dict(l=0, r=0, t=30, b=0))
        st.plotly_chart(fig_t1, use_container_width=True)

    with col_t2:
        st.markdown("##### 🔻 Transition Rates: Class 10 → Class 11")
        cohort_sec = filtered_cohort.groupby('social_category').agg(
            c10_boys=('enr_c10_boys_23', 'sum'),
            c10_girls=('enr_c10_girls_23', 'sum'),
            c11_boys=('enr_c11_boys_24', 'sum'),
            c11_girls=('enr_c11_girls_24', 'sum')
        ).reset_index()
        
        cohort_sec['boys_sec_t'] = (cohort_sec['c11_boys'] / cohort_sec['c10_boys'] * 100).clip(upper=100).round(1)
        cohort_sec['girls_sec_t'] = (cohort_sec['c11_girls'] / cohort_sec['c10_girls'] * 100).clip(upper=100).round(1)
        
        sec_rate_df = pd.melt(cohort_sec, id_vars=['social_category'], value_vars=['boys_sec_t', 'girls_sec_t'],
                              var_name='Cohort', value_name='Transition_Rate')
        sec_rate_df['Cohort'] = sec_rate_df['Cohort'].replace({'boys_sec_t': 'Boys (10→11)', 'girls_sec_t': 'Girls (10→11)'})
        
        fig_t2 = px.bar(
            sec_rate_df,
            x='social_category',
            y='Transition_Rate',
            color='Cohort',
            barmode='group',
            color_discrete_map={'Boys (10→11)': '#2563EB', 'Girls (10→11)': '#DB2777'},
            labels={'social_category': 'Social Category', 'Transition_Rate': 'Transition Rate (%)'},
            title="Class 10 → 11 Transition Rate by Social Category"
        )
        fig_t2.update_layout(height=380, yaxis_range=[40, 105], margin=dict(l=0, r=0, t=30, b=0))
        st.plotly_chart(fig_t2, use_container_width=True)

    st.markdown("---")
    st.markdown("##### 🚽 Sanitation Factor: Functional Girls Toilets vs Girls Retention")
    
    # Analyze correlation between functional girls toilet and transition
    dist_san = filtered_dist.groupby('district').agg(
        schools=('school_count', 'sum'),
        schools_with_gt=('schools_with_girls_toilet', 'sum'),
        total_girls_enr=('total_girls_24', 'sum'),
        avg_infra=('avg_infra_score_23', 'mean')
    ).reset_index()
    dist_san['toilet_pct'] = (dist_san['schools_with_gt'] / dist_san['schools'].clip(lower=1) * 100).clip(upper=100).round(1)
    
    fig_scatter = px.scatter(
        dist_san,
        x='toilet_pct',
        y='avg_infra',
        size='total_girls_enr',
        color='toilet_pct',
        color_continuous_scale=['#EF4444', '#F59E0B', '#10B981'],
        hover_name='district',
        labels={'toilet_pct': '% Schools with Functional Girls Toilet', 'avg_infra': 'Composite Infrastructure Score (0-7)'},
        title="District Sanitation Penetration vs Infrastructure Strength"
    )
    fig_scatter.update_layout(height=420, margin=dict(l=0, r=0, t=30, b=0))
    st.plotly_chart(fig_scatter, use_container_width=True)

# -----------------------------------------------------------------------------
# TAB 3: Infrastructure & RTE Compliance
# -----------------------------------------------------------------------------
with tab3:
    st.subheader("Physical Amenities, Digital Infrastructure & PTR Compliance")
    
    col_i1, col_i2 = st.columns([1, 1])
    
    with col_i1:
        st.markdown("##### 🔌 Basic Amenities Penetration (% of Total Schools)")
        tot_sch = filtered_dist['school_count'].sum()
        infra_summary = pd.DataFrame({
            'Facility': [
                'Electricity',
                'Functional Girls Toilet',
                'Library',
                'Playground',
                'Internet Connectivity',
                'Computer / ICT Lab',
                'Smart Classroom / TV'
            ],
            'Schools_Equipped': [
                filtered_dist['schools_with_electricity'].sum(),
                filtered_dist['schools_with_girls_toilet'].sum(),
                filtered_dist['schools_with_library'].sum(),
                filtered_dist['schools_with_playground'].sum(),
                filtered_dist['schools_with_internet'].sum(),
                filtered_dist['schools_with_comp_lab'].sum(),
                filtered_dist['schools_with_smart_tv'].sum()
            ]
        })
        infra_summary['Penetration_Pct'] = (infra_summary['Schools_Equipped'] / tot_sch * 100).round(1)
        infra_summary = infra_summary.sort_values(by='Penetration_Pct', ascending=True)
        
        fig_infra = px.bar(
            infra_summary,
            x='Penetration_Pct',
            y='Facility',
            orientation='h',
            text='Penetration_Pct',
            color='Penetration_Pct',
            color_continuous_scale='Blues',
            labels={'Penetration_Pct': 'Penetration (%)', 'Facility': 'Amenity'},
            title="School Infrastructure Availability"
        )
        fig_infra.update_traces(texttemplate='%{text}%', textposition='outside')
        fig_infra.update_layout(height=420, xaxis_range=[0, 115], margin=dict(l=0, r=0, t=30, b=0))
        st.plotly_chart(fig_infra, use_container_width=True)

    with col_i2:
        st.markdown("##### 👥 RTE Pupil-Teacher Ratio (PTR) Staffing Status")
        # Classify PTR
        filtered_dist_copy = filtered_dist.copy()
        filtered_dist_copy['computed_ptr'] = (filtered_dist_copy['total_enr_23'] / filtered_dist_copy['total_tch_23'].replace(0, np.nan)).round(1)
        
        def categorize_ptr(row):
            ptr = row['computed_ptr']
            if pd.isna(ptr):
                return 'No Teachers Reported'
            elif ptr > 35:
                return 'Critical Under-staffed (PTR > 35)'
            elif ptr > 30:
                return 'Moderate Under-staffed (30 < PTR ≤ 35)'
            elif ptr < 10:
                return 'Over-staffed / Surplus (PTR < 10)'
            else:
                return 'RTE Compliant (10 ≤ PTR ≤ 30)'
                
        filtered_dist_copy['staffing_status'] = filtered_dist_copy.apply(categorize_ptr, axis=1)
        ptr_counts = filtered_dist_copy['staffing_status'].value_counts().reset_index()
        ptr_counts.columns = ['Status', 'Count']
        
        fig_ptr = px.pie(
            ptr_counts,
            values='Count',
            names='Status',
            hole=0.45,
            color='Status',
            color_discrete_map={
                'RTE Compliant (10 ≤ PTR ≤ 30)': '#10B981',
                'Moderate Under-staffed (30 < PTR ≤ 35)': '#F59E0B',
                'Critical Under-staffed (PTR > 35)': '#EF4444',
                'Over-staffed / Surplus (PTR < 10)': '#60A5FA',
                'No Teachers Reported': '#9CA3AF'
            },
            title="Staffing Compliance Against RTE Norms"
        )
        fig_ptr.update_layout(height=420, margin=dict(l=0, r=0, t=30, b=0))
        st.plotly_chart(fig_ptr, use_container_width=True)

    if not df_nfhs.empty:
        st.markdown("---")
        st.markdown("##### 🩺 Health & Educational Overlap: NFHS-5 Child Anemia vs Infrastructure")
        state_health = filtered_dist.groupby('state').agg(
            avg_infra=('avg_infra_score_23', 'mean'),
            schools=('school_count', 'sum')
        ).reset_index().merge(df_nfhs, on='state', how='inner')
        
        if not state_health.empty:
            fig_health = px.scatter(
                state_health,
                x='child_anemia_rate_pct',
                y='avg_infra',
                size='schools',
                text='state',
                labels={'child_anemia_rate_pct': 'NFHS-5 Child Anemia Rate (%)', 'avg_infra': 'Avg School Infra Score'},
                title="Cross-Sector Analysis: State Child Nutrition vs School Infrastructure",
                color='avg_infra',
                color_continuous_scale='Viridis'
            )
            fig_health.update_traces(textposition='top center')
            fig_health.update_layout(height=450, margin=dict(l=0, r=0, t=30, b=0))
            st.plotly_chart(fig_health, use_container_width=True)

# -----------------------------------------------------------------------------
# TAB 4: District Intervention Matrix
# -----------------------------------------------------------------------------
with tab4:
    st.subheader("🎯 District-Level Action Matrix & Policy Priority Scoring")
    st.markdown("Drill down to specific districts to identify critical needs and export priority intervention lists.")

    selected_st = st.selectbox("Select State for Deep Dive", options=sorted(filtered_dist['state'].unique()))
    dist_state_df = filtered_dist[filtered_dist['state'] == selected_st]
    
    district_summary = dist_state_df.groupby('district').agg(
        schools_24=('school_count_24', 'sum'),
        students_24=('total_enr_24', 'sum'),
        boys_24=('total_boys_24', 'sum'),
        girls_24=('total_girls_24', 'sum'),
        growth_pct=('enr_growth_pct', 'mean'),
        avg_infra=('avg_infra_score_23', 'mean'),
        girls_toilet_schools=('schools_with_girls_toilet', 'sum')
    ).reset_index()

    district_summary['gpi'] = (district_summary['girls_24'] / district_summary['boys_24'].replace(0, np.nan)).round(3)
    district_summary['toilet_coverage_pct'] = (district_summary['girls_toilet_schools'] / district_summary['schools_24'].clip(lower=1) * 100).clip(upper=100).round(1)
    
    def flag_district(row):
        flags = []
        if row['avg_infra'] < 4.0:
            flags.append("Low Infrastructure (<4.0)")
        if row['toilet_coverage_pct'] < 75.0:
            flags.append("Sanitation Deficit (<75%)")
        if row['gpi'] < 0.95:
            flags.append("Gender Disparity (GPI < 0.95)")
        if row['growth_pct'] < -5.0:
            flags.append("Enrollment Contraction (<-5%)")
        return " | ".join(flags) if flags else "Adequate / Satisfactory"
        
    district_summary['action_priority'] = district_summary.apply(flag_district, axis=1)
    district_summary = district_summary.sort_values(by=['avg_infra', 'toilet_coverage_pct'], ascending=True)

    # Filter by Priority
    priority_filter = st.radio(
        "Show Districts:",
        options=["All Districts", "High-Priority Interventions Only"],
        horizontal=True
    )
    if priority_filter == "High-Priority Interventions Only":
        display_df = district_summary[district_summary['action_priority'] != "Adequate / Satisfactory"]
    else:
        display_df = district_summary

    st.dataframe(
        display_df.style.format({
            'schools_24': '{:,}',
            'students_24': '{:,}',
            'boys_24': '{:,}',
            'girls_24': '{:,}',
            'growth_pct': '{:+.2f}%',
            'avg_infra': '{:.2f}/7',
            'toilet_coverage_pct': '{:.1f}%',
            'gpi': '{:.3f}'
        }),
        use_container_width=True,
        height=400
    )

    csv_data = display_df.to_csv(index=False).encode('utf-8')
    st.download_button(
        label="📥 Download Filtered District Priority Report (CSV)",
        data=csv_data,
        file_name=f"UDISE_Intervention_Priority_{selected_st}.csv",
        mime="text/csv"
    )

# -----------------------------------------------------------------------------
# TAB 5: Pipeline Architecture & dbt Models
# -----------------------------------------------------------------------------
with tab5:
    st.subheader("⚙️ Modern Data Stack (MDS) Architecture & Modeling Specifications")
    
    col_a1, col_a2 = st.columns(2)
    
    with col_a1:
        st.markdown("""
        #### 🏗️ End-to-End Pipeline
        1. **Raw Ingestion Layer:**
           - Nationwide CSVs (~4 GB across 2023–24 and 2024–25 academic years).
           - 6 core entity files: `enrollment1`, `enrollment2`, `facilities`, `profile1`, `profile2`, `teachers`.
        2. **Big Data Processing (PySpark):**
           - Batch conversion from raw multi-GB CSVs to columnar Parquet format.
        3. **Relational Warehousing (DuckDB & PostgreSQL):**
           - Direct bulk ingestion from Parquet into PostgreSQL 16 database.
        4. **Analytics Engineering (dbt):**
           - Two-tier dbt architecture (10 staging views + 21 analytics marts) with 76 automated schema tests.
        5. **Semantic & Presentation Layer:**
           - Pre-aggregated dimensional marts (`powerbi_exports`) serving Streamlit and BI tools.
        """)

    with col_a2:
        st.markdown("#### 📦 Catalog of 21 dbt Models")
        models_data = {
            "Model Domain": [
                "Girls Retention vs Infrastructure",
                "Pupil-Teacher Ratio (PTR)",
                "Composite Infrastructure Score",
                "Regional & Social Disparities",
                "Socio-Economic & Health Proxies",
                "Management & Facility Impact",
                "Aspirational Districts Retention",
                "Secondary Transition Bottlenecks",
                "CWSN Disability Disaggregation",
                "Age-Grade Distortion (Class 1)",
                "Student Progression Funnel"
            ],
            "Baseline Model (2023-24)": [
                "girls_retention_vs_infra",
                "ptr_and_teacher_allocation",
                "infra_score_vs_enrollment",
                "regional_social_disparities",
                "socio_economic_and_health_proxies",
                "school_management_and_facility_impact",
                "girls_retention_aspirational_districts",
                "transition_bottlenecks",
                "cwsn_enrolment_disability",
                "age_grade_distortion",
                "student_progression_funnel"
            ],
            "YoY Comparison (23-24 vs 24-25)": [
                "yoy_girls_retention_vs_infra",
                "yoy_ptr_and_teacher_allocation",
                "yoy_infra_score_vs_enrollment",
                "yoy_regional_social_disparities",
                "yoy_socio_economic_and_health_proxies",
                "yoy_school_management_and_facility_impact",
                "yoy_girls_retention_aspirational_districts",
                "yoy_transition_bottlenecks",
                "yoy_cwsn_enrolment_disability",
                "yoy_age_grade_distortion",
                "—"
            ]
        }
        st.dataframe(pd.DataFrame(models_data), use_container_width=True, height=400)
