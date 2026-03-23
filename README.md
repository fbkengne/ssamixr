**Social Contact Matrices for Sub‑Saharan Africa**

`ssamixr` provides harmonized, ready‑to‑use social contact matrices from empirical studies conducted across Sub‑Saharan Africa.  
The package includes **171 matrices** covering multiple countries, settings, and study designs — all standardized for infectious 
disease modeling and comparative epidemiology.

# 🚀 Installation

```r
# Install devtools if needed
if (!requireNamespace("devtools", quietly = TRUE)) {
  install.packages("devtools")
}

# Install ssamixr from GitHub
devtools::install_github("fbkengne/ssamixr")

# Load the package
library(ssamixr)
```

🧭 Getting Started: A Simple Workflow <br>
Most users will want to:

1. List all available matrices
2. Filter matrices by country, study, or location
3. Select a matrix ID
4. Retrieve the matrix
5. Visualize it

Here is the recommended workflow.

1️⃣ List all matrices

```r
library(ssamixr)

all_mats <- list_matrices()
head(all_mats)
```

This returns a tibble with metadata for all 171 matrices.

2️⃣ Filter matrices <br>
You can filter by:

- country
- study_id
- author_year
- location_type (All, HH, School, Work, Other)

Example: matrices from Kenya:

```r
kenya <- filter_matrices(country = "Kenya")
```

Example: household (HH) matrices:

```r
hh <- filter_matrices(location_type = "HH")
```

Example: combine filters:

```r
kenya_hh <- filter_matrices(country = "Kenya", location_type = "HH")
```

3️⃣ Select a matrix ID

```r
id <- kenya$matrix_id[1]
id
```

4️⃣ Retrieve the matrix

```r
m <- get_matrix(id)
m$matrix      # numeric matrix
m$row_labels  # participant age groups
m$col_labels  # contact age groups
```

5️⃣ Visualize the matrix

```r
plot_matrix(m)
```

Or with a gradient:

```r
plot_matrix_gradient(m)
```

📊 Dataset Summary <br>
The package contains:

- 171 social contact matrices
- covering 18 Sub‑Saharan African countries
- In Multiple settings:
  . All locations (All)
  . Household (HH)
  . School
  . Work
  . Other settings (Other)

- Each matrix includes:<br>

  . A numeric contact matrix<br>
  . Age‑group labels<br>
  . Study metadata<br>
  . Location type<br>
  . Country and author‑year identifiers<br>

🌍 Countries Included:<br>
The package includes matrices from the following 18 countries: <br>

- Angola
- Burkina Faso
- Cameroon
- Democratic Republic of Congo
- Ethiopia
- Gambia
- Ghana
- Guinea
- Ivory Coast
- Kenya
- Malawi
- Mozambique
- Nigeria
- Senegal
- South Africa
- Uganda
- Zambia
- Zimbabwe

(If you want, you can auto‑generate this list directly from the metadata.)

🏷️ Filtering Options<br>
Users can filter matrices using the following metadata fields:

Field	Description<br>
country:	Country name (18 total)<br>
study_id:	Unique study identifier<br>
author_year:	Author + publication year label<br>
location_type:	Contact setting: All, HH, School, Work, Other<br>

Example:

```r
filter_matrices(
  country = c("Kenya", "Uganda"),
  location_type = "School"
)
```

📦 Overview<br>
ssamixr provides:<br>

Age‑structured social contact matrices for Sub‑Saharan African countries
Harmonized metadata for filtering and selection
Tools for loading, inspecting, and visualizing matrices

A reproducible workflow for integrating matrices into transmission models
Designed for:
- Infectious disease modelers
- Public health researchers
- Policy analysts
- Students learning age‑structured modeling

🌍 Data Sources<br>
The matrices included in ssamixr are derived from:
- Empirical contact surveys conducted across Sub‑Saharan Africa
- Harmonized demographic data
- Standardized processing pipelines ensuring comparability

Full details are available in the package vignette:

```r
vignette("ssamixr")
```

📁 Package Structure<br>
ssamixr/<br>
├── R/                 # Functions<br>
├── data/              # Internal datasets<br>
├── inst/              # Metadata and documentation<br>
├── vignettes/         # Long-form documentation<br>
└── dev/               # Development scripts<br>

🤝 Contributing<br>
Contributions are welcome.<br>
If you would like to:<br>
- Add new matrices
- Improve documentation
- Report issues
- Suggest enhancements

please open an issue or submit a pull request on GitHub.

📄 License<br>
This package is released under the MIT License.
See LICENSE for details.

📄 Appendix: Full Social Contact Matrix Catalogue<br>
A complete appendix summarizing all 171 social contact matrices across 18 Sub‑Saharan African countries, including:<br>
- matrix counts by country<br>
- location types (household, school, work, other)<br>
- rural/urban distribution<br>
- COVID‑19 vs pre‑COVID periods<br>
- heatmaps and descriptions for each country<br>

The appendix is available in the package at:

```r
system.file("extdata", "social_contact_appendix.pdf", package = "ssamixr")
```

📬 Citation<br>
If you use ssamixr in your research, please cite:<br>

Kengne FB, et al. (2026). ssamixr: Social Contact Matrices for Sub‑Saharan Africa.
A full citation entry is available via:<br>

```r
citation("ssamixr")
```

🧪 Reproducibility<br>
This package follows best practices for reproducible research:<br>

- Version‑controlled development<br>
- Documented data processing pipelines<br>
- Vignettes demonstrating usage<br>
- Stable GitHub releases with DOIs (via Zenodo)<br>

🙏 Acknowledgments<br>
We thank the researchers, survey teams, and collaborators who contributed to the collection and harmonization of social contact data across Sub‑Saharan Africa.
