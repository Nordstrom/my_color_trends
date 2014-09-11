import pandas as pdgasdsfsf
import numpy as np
import random
import collections
import pdb
import itertools

#pd.option('display.max_columns', 50)

""" Data Processing """

# JV's Pantone tables
#pantone = pd.read_csv('/Users/x1lh/projects/color/data/pantone_all.tsv', 
#    sep = '\t')

x11 = pd.read_csv('/Users/x1lh/projects/color/data/x11_all_with_headers.tsv',
    header = 0,
    sep = '\t')

# Transactional data
trans = pd.read_csv('/Users/x1lh/projects/color/data/leadership_tran_data_no_quotes.txt', 
    header = 0, 
    sep = '\t')

# Product catalog
historical_catalog = pd.read_csv('/Users/x1lh/projects/color/data/historical_product_catalog.txt', 
    header = 0, 
    sep = '\t')

# remove empty white space from some elements
historical_catalog['description'] = historical_catalog['description'].map(str.strip)
historical_catalog['age_group'] = historical_catalog['age_group'].map(str.strip)
historical_catalog['gender'] = historical_catalog['gender'].map(str.strip)


# filter out categories in the 'bad_categories' list below.
historical_catalog['bad_cat'] = historical_catalog['description'].isin(bad_categories)
historical_catalog = historical_catalog[(historical_catalog.bad_cat == False)]

# merge catalog with color. 
historical_catalog = pd.merge(catalog, 
    x11[['rms_sku_id', 'color_name', 'color_id']], 
    left_on = 'rms_sku_id', 
    right_on = 'rms_sku_id')

current_catalog = pd.read_csv('/Users/x1lh/projects/color/data/product_catalog.txt',
    header = 0, 
    sep = '\t')
current_catalog.columns = map(str.lower, current_catalog.columns) 

# Remove items in non-recommendable categories
#current_catalog.mrch_ctgry_lvl2 = current_catalog.mrch_ctgry_lvl2.str.split()
current_catalog['bad_cat_merch1'] = current_catalog['mrch_ctgry_lvl1'].isin(bad_categories)
current_catalog['bad_cat_merch2'] = current_catalog['mrch_ctgry_lvl2'].isin(bad_categories)
current_catalog = current_catalog[(current_catalog.bad_cat_merch1 == False) & (current_catalog.bad_cat_merch2 == False)]

## Recode shit in the current catalog to match the historical catalog
age_recodes = {'Adult': 'A', 'Infant': 'I', 'Youth': 'Y', 'Toddler': 'T', 'None': 'N', 'Teen': 'E'}
current_catalog['web_prdct_age'] = current_catalog['web_prdct_age'].map(age_recodes)

# Merge rgb data with product catalog
current_catalog = pd.merge(current_catalog, 
    x11[['rms_sku_id', 'color_name', 'color_id']], 
    left_on = 'chld_sku_id', 
    right_on = 'rms_sku_id')

# Merge color data with transaction histories
data = pd.merge(trans[['CUST_KEY', 'TRAN_KEY', 'BUS_DT', 'sku_idnt']], 
    catalog_merge, 
    left_on = "sku_idnt", 
    right_on = "rms_sku_id")

no_dups = data.drop_duplicates(['CUST_KEY', 'sku_idnt', 'color_id'])

no_dups.to_csv('/Users/x1lh/projects/color/data/color_transactions.tsv', sep = '\t')

## Catagories to remove
bad_categories = [
  'Aquatic',
  'Aprons',
  'Baby Stroller/Car Seat/Carrier',
  'Backpack',
  'Bath Accessories',
  'Bath Additive/Aromatherapy',
  'Bathroom Accessories',
  'Bedding/Blanket',             
  'Bedding/Comforters', 
  'Bedding/Pillow',                   
  'Bedding/Sham', 
  'Bedding/Sheets',
  'Bib',
  'Book',
  'Booties',
  'Boxer',
  'Bra',
  'Braces',
  'Briefcase',
  'Brow',
  'Brush',
  'Camisole',
  'Candle',
  'Card Holders',             
  'Carpets/Rugs', 
  'Cases & Covers',
  'Cashmere brush', 
  'CD/Music',                          
  'Chair', 
  'Cheek',
  'Cleanser',                         
  'Clocks', 
  'Clog',
  'Clutch', 
  'Coin Purses',                      
  'Corkscrew', 
  'Cover-up',
  'Cup/Spoon/Feeding Accessories',
  'Decoration',                     
  'Diaper bag', 
  'DNU - Ceramics',                          
  'Dolls',
  'DVD/Video/Movie',                       
  'Earmuffs', 
  'Eye',
  'Eyewear Accessories',
  'Foundation',                         
  'Frames',
  'Gadget / Tool',
  'Games',                    
  'Garment bag',
  'Garter',         
  'Gift Set (BEAUTY ONLY)', 
  'Gift w/Purchase',
  'Gloves',
  'Goggles',
  'Gown', 
  'Gym bag',
  'Hair accessories',
  'Hand & Body',
  'Hooded towel',
  'Insoles',
  'Jewelry Box',
  'Jumper',                
  'Jumpsuit/Romper', 
  'Key Holders',                          
  'Laces', 
  'Laptop bag',                           
  'Lash', 
  'Lighting',                  
  'Lingerie wash', 
  'Lip',
  'Makeup application',                    
  'Makeup case', 
  'Messenger bag',                        
  'Mirrors', 
  'Miscellaneous',                        
  'Mittens', 
  'Moisturizer',
  'Nail care',                     
  'Nail Color', 
  'Napkins',
  'Nightgown',                         
  'Onesie', 
  'Organizer',                          
  'Other', 
  'Pajama bottom',                     
  'Pajama set', 
  'Panty/Brief',
  'Pantyhose/Nylons',                   
  'Pareo/sarong',
  'PDA case',                        
  'Perfume', 
  'Pet care',
  'Pin',
  'Polish',
  'Powder',
  'Robe',
  'Self tanner',                            
  'Set',
  'Shaper/Control',                   
  'Shaving case', 
  'Shaving Cream/Gel',
  'Shoe tree',
  'Sleeper',                           
  'Slip', 
  'Soap',
  'Sports Equipment',
  'Stationery/Cards',
  'Stockings',
  'Stuffed Animals',            
  'Suitcase (carry-on)', 
  'Suitcase (large)',                     
  'Sunglasses',
  'Swim bottom', 
  'Swim top',                     
  'Swim trunk', 
  'Swimsuit (complete)',
  'Table Placements',
  'Teddy',
  'Teething ring/Pacifier',
  'Thermal',
  'Throws',
  'Tights',
  'Toner',
  'Tote',            
  'Towel (Bath/Beach)', 
  'Tray (Decorative)',                          
  'Trunk', 
  'Umbrella',                     
  'Undershirt',
  'Visor',
  'Wallets',
  'Winecharm',                   
  'Winestoppers']

no_dups['description'] = no_dups.description.str.strip()
no_dups['bad_cat'] = no_dups['description'].isin(bad_categories)
no_undies = no_dups[(no_dups.bad_cat == False)]
no_undies['age_group'] = no_undies.age_group.str.strip()
no_undies = no_undies[(no_undies.age_group == 'A')]
no_undies.to_csv('/Users/x1lh/projects/color/data/color_transactions_no_undies.tsv', sep = '\t')

# Generate additional RGB variables
data[['r', 'g', 'b']] = pd.DataFrame(data['rgb']
    .str.replace('{', '')
    .str.replace('}', '')
    .str.split(',', 3)
    .tolist(), dtype = float)

data[['r_perc', 'g_perc', 'b_perc']] = data[['r', 'g', 'b']] / 255.0

## Read in complimentary color sets
color_sets = pd.read_csv('/Users/x1lh/projects/color/data/complementary_colors_full_x11.txt',
    header = 0, 
    sep = '\t')

# Parse up the rules
color_sets[['lhs', 'rhs']] = color_sets['rules'].str.replace('{', '').str.replace('}', '').str.split(' => ').apply(lambda x: pd.Series({'lhs': x[0], 'rhs': x[1]}))
color_sets['lhs'] = color_sets['lhs'].str.split

# 1. Grab unique product ids
purchased = data[['sku_idnt', 'gender', 'product_type', 'color_name']].drop_duplicates().sort(['sku_idnt'])

"""
# We are short 5 ids.
missing = []
for id in all_ids:
  if id not in trans.CUST_KEY.unique().tolist():
    missing.append(id)

[53484136, 47933520, 26565630, 32254922, 57046453, 34235323]
"""
# TODO: Remove undies

data['hex'] = data.apply(lambda x: rgb_to_hex(x), axis = 1)

# Sample customer
# TODO: For items of multiple colors subset to the majority color
customer_data = no_undies[['CUST_KEY', 'web_style_id', 'color_name', 'color_percent']].drop_duplicates()
customer_data = customer_data.sort(['CUST_KEY', 'web_style_id', 'color_percent'], ascending = False)

"""
#Testing
style_id = '3108504'
color = 'Tan'

style_id = '2956246'
color = 'Medium Violet Red'
"""
grouped = customer_data.groupby(['CUST_KEY', 'web_style_id']).first()
recs_out = grouped.apply(lambda x: generate_matching_recs(x['web_style_id'], x['color_name'], historical_catalog, current_catalog))

## Testing
customer_sub = customer_data[(customer_data.CUST_KEY.isin([57667519, 56547410, 55911968]))]
customer_sub = customer_sub[['CUST_KEY', 'color_name']].drop_duplicates()

recs_export = customer_sub['color_name'].apply(lambda x: generate_simple_matching_recs(x, historical_catalog, current_catalog), axis = 1)

generate_matching_recs(style_id, color, historical_catalog, current_catalog)

# TODO: Eventually shove all these functions into a class
def rgb_to_hex(x):
  """ Convert RGB values into color hexes """
  return '#%02x%02x%02x' % (x['r'], x['g'], x['b'])

def generate_matching_recs(style_id, color, historical_catalog, current_catalog, rec_type = 'same'):
  
  """ Returns products in the same color as target product """
  # TODO: Add additional argument that takes color clusters if we eventually want to bin colors
  # into broader groups.
  # TODO: Need to include img URL override for stuff with multiple colors
  recs = pd.DataFrame(columns = ['target_style_id', 'rec_type', 'gender', 'category', 'color_name', 'color_id', 'age', 'recommended_style', 'recommended_category', 'image_url', 'product_url']) 

  # Grab category attributes for the input product from the catalog
  gender = historical_catalog[(historical_catalog.web_style_id == int(style_id))].gender.unique()[0]
  age = historical_catalog[(historical_catalog.web_style_id == int(style_id))].age_group.unique()[0]
  category = historical_catalog[(historical_catalog.web_style_id == int(style_id))].description.unique()[0]

  # Subset the catalog to match color, gender and NOT the same category 
  matching_products = current_catalog[(current_catalog.color_name == color) 
      & (current_catalog.mrch_ctgry_lvl2 != category) 
      & (current_catalog.prdct_gndr == gender)
      & (current_catalog.web_prdct_age == age)]

  category_list = matching_products.mrch_ctgry_lvl2.unique().tolist()

  for cat in category_list:
    candidates = matching_products[(matching_products.mrch_ctgry_lvl2 == cat)]
    random_candidate = candidates.ix[random.sample(candidates.index, 1)]

    recs = recs.append({'target_style_id': style_id,
        'rec_type': rec_type,
        'gender': gender, 
        'category': category, 
        'color_name': color,
        'color_id': random_candidate.color_id.iloc[0], 
        'age': age,
        'recommended_style': int(random_candidate.web_style_id),
        'recommended_category': cat,
        'image_url': random_candidate.sku_img_url.iloc[0],
        'product_url': random_candidate.web_style_hostd_url.iloc[0]
    }, ignore_index = True)

  return recs

def generate_complementary_recs(style_id, colors, rules):
  
  """ Returns products in colors that are complementary to the target """

  complements = get_complement_colors(color, rules)

  recs = []
  for complement in complements:
    # Subset the catalog to match color, gender and NOT the same category 
    recs.append(generate_matching_recs(style_id, complement))
  return recs
 
def get_complement_colors(color, rules):

  # TODO: Would be really cool to recommend color combos based on rules of the
  # form color 1, color 2 ==> color 3
  if len([color]) == 1:
    subset = rules[(rules.lhs == color)].sort('lift', ascending = False).head(15)
    return subset.rhs.tolist()


def generate_simple_matching_recs(color, historical_catalog, current_catalog, rec_type = 'same'):
  
  """ Returns products in the same color as target product """
  # TODO: Add additional argument that takes color clusters if we eventually want to bin colors
  # into broader groups.
  # TODO: Need to include img URL override for stuff with multiple colors
  recs = pd.DataFrame(columns = ['rec_type', 'color_name', 'color_id', 'recommended_style', 'recommended_category', 'image_url', 'product_url']) 

  # Subset the catalog to match color, gender and NOT the same category 
  matching_products = current_catalog[(current_catalog.color_name == color)
       & (current_catalog.web_prdct_age == 'A')]

  category_list = matching_products.mrch_ctgry_lvl2.unique().tolist()

  for cat in category_list:
    candidates = matching_products[(matching_products.mrch_ctgry_lvl2 == cat)]
    random_candidate = candidates.ix[random.sample(candidates.index, 1)]

    recs = recs.append({'rec_type': rec_type,
        'color_name': color,
        'color_id': random_candidate.color_id.iloc[0], 
        'recommended_style': int(random_candidate.web_style_id),
        'recommended_category': cat,
        'image_url': random_candidate.sku_img_url.iloc[0],
        'product_url': random_candidate.web_style_hostd_url.iloc[0]
    }, ignore_index = True)

  return recs

def generate_matching_recs(style_id, color, catalog):
  
  """ Returns products in the same color as target product """
  recs = []

  # Grab category attributes for the input product from the catalog
  gender = catalog[(catalog.web_style_id == int(style_id))].prdct_gndr.unique()[0]
  age = catalog[(catalog.web_style_id == int(style_id))].web_prdct_age.unique()[0]
  category = catalog[(catalog.web_style_id == int(style_id))].mrch_ctgry_lvl2.unique()[0]

  # Subset the catalog to match color, gender and NOT the same category 
  matching_products = catalog[(catalog.color_name == color) 
      & (catalog.mrch_ctgry_lvl2 != category) 
      & (catalog.prdct_gndr == gender)
      & (catalog.web_prdct_age == age)]

  # Retain 15 recommendations across all the potential categories
  recommended_styles = []
  recommended_categories = []

  # Grab all potential categories
  category_list = matching_products.product_type.unique().tolist()
  for category in category_list:
    candidates = matching_products[(matching_products.product_type == category)]
    random_candidate = candidates.ix[random.sample(candidates.index, 1)]
    style = str(random_candidate.web_style_id.tolist()[0])
    if style not in recommended_styles:
      recommended_styles.append(style)
      recommended_categories.append(random_candidate.mrch_ctgry_lvl2.tolist()[0])

  rec = {'target_style_id': style_id,
      'gender': gender, 
      'category': category, 
      'color': color, 
      'age': age,
      'recommended_styles': ','.join(recommended_styles[0:14]),
      'recommended_categories': ','.join(recommended_categories[0:14])
      }

  recs.append(rec)
  return rec
